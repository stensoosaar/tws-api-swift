//
//  Connection.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 07.06.2026.
//

@_exported import TWSModels

import NIOCore
import NIOPosix
import Foundation
import TWSModels


/// One API session with TWS or IB Gateway.
///
/// After `connect()` succeeds the connection keeps itself up: when the socket breaks it reconnects
/// by the `Connection.Configuration.reconnect` policy and re-runs the API start. `messages()` is
/// one stream for the whole life of the connection. Link changes (socket lost and restored, gateway
/// offline/online, farm notices) arrive in it as `Response.status(_:)`, in order with the data. Everything
/// the client had requested (market data, account updates, orders streams) is gone after a socket
/// loss and has to be requested again when `.status(.connected(reconnect: true))` arrives.
/// `disconnect()` ends the stream and stops any reconnecting.
public final class Connection: @unchecked Sendable {
	
	let config: Connection.Configuration
	
	private var channel: Channel?
	
	private var isConnected = false
	
	private enum ConnectionState: Sendable {
		case idle
		case tcpConnecting
		case tcpConnected
		case handshakeSent
		case handshakeComplete
		case startingApi
		case apiStarted
		case reconnecting
		case disconnecting
		case disconnected
		case failed(ConnectionError)
	}
	
	private var state: ConnectionState = .idle
	
	private var serverVersion: Int?
		
	public private(set) var connectionTime: String?
	
	public private(set) var managedAccounts: [String] = []
	
	
	// Message handling
	private var messageStream: AsyncStream<Response>?
	private var messageContinuation: AsyncStream<Response>.Continuation?
	private var startupStream: AsyncStream<Response>?
	private var startupContinuation: AsyncStream<Response>.Continuation?
	
	// Handshake handling
	private var handshakePromise: EventLoopPromise<HandshakeResponse>?
	private var pendingHandshakeResult: Result<HandshakeResponse, Error>?
	private var handshakeHandler: HandshakeHandler?
	
	// Reconnect handling (all on the event loop)
	
	/// Counts connect attempts. Callbacks of an earlier attempt's channel carry an older number
	/// and are dropped, so a dying socket cannot disturb the attempt that replaced it.
	private var generation = 0
	/// `disconnect()` was called: nothing may reconnect or emit anymore.
	private var userClosed = false
	/// The API was up at least once on this connect, so a lost socket counts as an outage.
	private var sessionEstablished = false
	private var isReconnecting = false
	private var reconnectTask: Task<Void, Never>?
	
	private let eventLoopGroup: MultiThreadedEventLoopGroup
	private let eventLoop: EventLoop
	
	public var debug: Bool = false
	
	public let id: Int32

	public init(id: Int32, with config: Connection.Configuration) {
		self.id = id
		self.config = config
		self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
		self.eventLoop = eventLoopGroup.next()
	}
		
	deinit {
		let channel = self.channel
		let messageContinuation = self.messageContinuation
		let startupContinuation = self.startupContinuation
		eventLoop.execute {
			channel?.close(mode: .all, promise: nil)
			messageContinuation?.finish()
			startupContinuation?.finish()
		}
		if debug{
			print("connection \(id) shut down")
		}
	}

	// MARK: - EventLoop Helpers

	
	@inline(__always)
	private func onEventLoop<T: Sendable>(
		_ work: @escaping @Sendable () throws -> T   // ← add @Sendable
	) async throws -> T {
		if eventLoop.inEventLoop {
			return try work()
		}
		return try await eventLoop.submit { try work() }.get()
	}

	@inline(__always)
	private func onEventLoopFuture<T: Sendable>(
		_ work: @escaping @Sendable () throws -> EventLoopFuture<T>  // ← add @Sendable
	) async throws -> T {
		if eventLoop.inEventLoop {
			return try await work().get()
		}
		return try await eventLoop.submit { try work() }.flatMap { $0 }.get()
	}
	
	/// Runs `work` now when already on the event loop, otherwise schedules it there.
	private func runOnLoop(_ work: @escaping @Sendable () -> Void) {
		if eventLoop.inEventLoop {
			work()
		} else {
			eventLoop.execute(work)
		}
	}
	
	@inline(__always)
	private func assertEventLoop() {
		assert(eventLoop.inEventLoop, "Connection state must be accessed on the EventLoop.")
	}
	 
	
	// MARK: - Connection Management
	
	public func connect() async throws {
		try await beginConnecting()

		do {
			try await establishSession()
			try await onEventLoop {
				self.sessionEstablished = true
				self.emit(.connected(reconnect: false))
			}

			let connectedServerVersion = try await onEventLoop { self.serverVersion }
			if debug{
				print("\(Date().description) \t ✅ Connected to IB API (server \(connectedServerVersion.debugDescription))")
			}

		} catch {
			if debug{
				print("\(Date().description) \t ❌ Connection failed: \(error)")
			}
			await abandonAttempt()
			try? await onEventLoop {
				self.state = .failed(.connectionFailed(error.localizedDescription))
			}
			throw ConnectionError.connectionFailed(error.localizedDescription)
		}
	}

	/// Guards against a duplicate connect, prepares the first attempt and
	/// creates the message stream that lives until `disconnect()` or until reconnecting gave up.
	private func beginConnecting() async throws {
		try await onEventLoop {
			guard !self.isConnected, !self.isReconnecting else {
				throw ConnectionError.alreadyConnected
			}
			self.userClosed = false
			self.sessionEstablished = false
			self.prepareAttempt()
		}

		if debug{
			print("🔌 Connecting to \(config.host):\(config.port)...")
		}

		let (stream, continuation) = AsyncStream<Response>.makeStream()
		try await onEventLoop {
			self.messageStream = stream
			self.messageContinuation = continuation
		}
	}
	
	/// Resets everything that belongs to one attempt: a new generation, a fresh startup stream,
	/// no leftovers of an earlier handshake. The message stream is not touched.
	private func prepareAttempt() {
		assertEventLoop()
		generation += 1
		if let old = channel {
			old.close(promise: nil)
		}
		channel = nil
		handshakePromise = nil
		pendingHandshakeResult = nil
		handshakeHandler = nil
		let (stream, continuation) = AsyncStream<Response>.makeStream()
		startupStream = stream
		startupContinuation = continuation
		state = .tcpConnecting
	}
	
	/// TCP, handshake and API start. The whole attempt is bounded by `connectTimeout`: when it
	/// runs out, the handshake and startup waits are failed and the channel is closed.
	private func establishSession() async throws {
		let gen = try await onEventLoop { self.generation }
		let seconds = Int(config.connectTimeout.rounded(.up))
		let watchdog = eventLoop.scheduleTask(in: connectTimeoutAmount) { [weak self] in
			self?.abortAttempt(
				generation: gen,
				reason: ConnectionError.connectionFailed("timed out after \(seconds)s")
			)
		}
		defer { watchdog.cancel() }

		let bootstrap = try await makeBootstrap(generation: gen)
		let channel = try await establishTCPConnection(using: bootstrap)

		try await performHandshake(on: channel)
		try await installProtobufPipeline(on: channel, generation: gen)
		try await onEventLoop { self.isConnected = true }

		try await startApiAndAwaitReady()
		try await onEventLoop { self.state = .apiStarted }
	}
	
	private var connectTimeoutAmount: TimeAmount {
		.seconds(Int64(config.connectTimeout.rounded(.up)))
	}
	
	/// Fails whatever the attempt is waiting on, so it throws instead of hanging.
	private func abortAttempt(generation gen: Int, reason: ConnectionError) {
		assertEventLoop()
		guard gen == generation else { return }
		completeHandshake(.failure(reason))
		startupContinuation?.finish()
		channel?.close(promise: nil)
	}
	
	/// Closes the channel of a failed attempt and marks the connection down.
	private func abandonAttempt() async {
		let channel = try? await onEventLoop { () -> Channel? in
			let current = self.channel
			self.channel = nil
			self.isConnected = false
			return current
		}
		if let channel {
			channel.close(promise: nil)
		}
	}

	/// Builds the NIO bootstrap with the frame decoder + handshake handler
	/// installed. The handshake handler is stashed on `self` here since
	/// `installProtobufPipeline` needs to remove it later.
	private func makeBootstrap(generation gen: Int) async throws -> ClientBootstrap {
		let handshakeHandler = HandshakeHandler { [weak self] result in
			guard let self else { return }
			self.runOnLoop { self.handleHandshakeResponse(result, generation: gen) }
		}
		try await onEventLoop { self.handshakeHandler = handshakeHandler }

		return ClientBootstrap(group: eventLoopGroup)
			.connectTimeout(connectTimeoutAmount)
			.channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
			.channelOption(ChannelOptions.socketOption(.tcp_nodelay), value: 1)
			.channelInitializer { @Sendable channel in
				channel.pipeline.addHandlers([
					ByteToMessageHandler(MessageFrameDecoder()),
					handshakeHandler
				])
			}
	}

	/// Dials the TCP connection and records the resulting channel + state.
	private func establishTCPConnection(using bootstrap: ClientBootstrap) async throws -> Channel {
		let channel = try await bootstrap.connect(host: config.host, port: config.port).get()

		try await onEventLoop {
			self.channel = channel
			self.state = .tcpConnected
		}

		if debug{
			print("\(Date().description) \t ✅ TCP connection established")
		}

		return channel
	}
	
	public func disconnect() async throws {
		let shouldDisconnect = try await onEventLoop { () -> Bool in
			// From here on nothing reconnects, whatever state the connection is in
			// (up, between two reconnect attempts, or in the middle of one).
			self.userClosed = true
			self.sessionEstablished = false
			self.isReconnecting = false
			self.reconnectTask?.cancel()
			self.reconnectTask = nil
			guard self.isConnected || self.channel != nil else {
				self.messageContinuation?.finish()
				self.messageContinuation = nil
				self.startupContinuation?.finish()
				self.startupContinuation = nil
				self.state = .disconnected
				return false
			}
			self.state = .disconnecting
			return true
		}
		guard shouldDisconnect else { return }
		if debug{
			print("Disconnecting \(id)...")
		}
		
		try await onEventLoop {
			self.abortAttempt(generation: self.generation, reason: ConnectionError.disconnected)
			self.messageContinuation?.finish()
			self.messageContinuation = nil
			self.startupContinuation?.finish()
			self.startupContinuation = nil
		}
		
		let channel = try await onEventLoop { self.channel }
		// The channel may already be closing (aborted attempt, dead socket): a failed close is fine.
		_ = try? await onEventLoopFuture {
			if let channel {
				return channel.close(mode: .all)
			}
			return self.eventLoop.makeSucceededVoidFuture()
		}
		try await onEventLoop {
			self.channel = nil
			self.isConnected = false
			self.state = .disconnected
			self.connectionTime = nil
			self.managedAccounts = []
			self.nextValidOrderID = nil
			self.handshakePromise = nil
			self.pendingHandshakeResult = nil
			self.handshakeHandler = nil
		}
		if debug{
			print("\(Date().description) \t \(id) Disconnected")
		}
	}

	
	private func installProtobufPipeline(on channel: Channel, generation gen: Int) async throws {
		// Remove the handshake handler now that the version negotiation is done.
		let handshakeHandler = try await onEventLoop { self.handshakeHandler }
		if let handshakeHandler {
			try await channel.pipeline.removeHandler(handshakeHandler).get()
			try await onEventLoop { self.handshakeHandler = nil }
		}
	
	   // let pacingHandler = ResponsePacingHandler(interval: .milliseconds(20))
	
		// Every callback is tied to this attempt's generation: once a newer attempt exists,
		// whatever this channel still reports is stale and dropped.
		let connectionHandler = ConnectionHandler(
			messageHandler: { [weak self] message in
				guard let self else { return }
				self.runOnLoop {
					guard gen == self.generation else { return }
					self.handleInboundMessage(message)
				}
			},
			errorHandler: { [weak self] error in
				guard let self else { return }
				self.runOnLoop {
					guard gen == self.generation else { return }
					self.handleInboundError(error)
				}
			},
			connectionStateHandler: { [weak self] state in
				guard let self else { return }
				self.runOnLoop {
					guard gen == self.generation else { return }
					self.handleConnectionState(state)
				}
			}
		)
	
		// Inbound-only pipeline.
		// MessageFrameDecoder is already in the pipeline from the bootstrap initializer.
		// ProtobufDecoder reads [msgId][proto] and emits ResponseEnvelope.
		// No outbound handlers — sendRequest(_:) writes a pre-framed ByteBuffer directly.
		try await channel.pipeline.addHandlers([
			ProtobufDecoder(),
		   // pacingHandler,
			connectionHandler
		]).get()
	}
	
	private func startApiAndAwaitReady() async throws {
		try await onEventLoop { self.state = .startingApi }
		try await sendStartAPI()

		let startupStream = try await onEventLoop { self.startupStream }
		guard let startupStream else {
			throw ConnectionError.invalidServerResponse
		}
				
		var hasManagedAccounts = false
		var hasNextOrderID = false
		
		for await message in startupStream {
			
			switch message{
			case .managedAccounts(let identifiers):
				hasManagedAccounts = true
				try await onEventLoop { self.managedAccounts = identifiers }

			case .nextOrderID:
				hasNextOrderID = true
			
			default:
				break
			}
			
			if hasManagedAccounts && hasNextOrderID {
				break
			}
		}
		
		try await onEventLoop {
			self.startupContinuation?.finish()
			self.startupContinuation = nil
			self.startupStream = nil
		}
		
		if !hasNextOrderID {
			throw ConnectionError.invalidServerResponse
		}
	}
	
	// MARK: - reconnecting
	
	/// The socket is gone. Decides between reconnecting and ending the stream.
	private func connectionDropped(reason: String) {
		assertEventLoop()
		isConnected = false
		
		// disconnect() is closing the channel itself.
		if userClosed { return }
		
		// Already reconnecting (second callback of the same drop, or an attempt that died):
		// the running attempt notices through its startup stream.
		if isReconnecting {
			startupContinuation?.finish()
			return
		}
		
		if sessionEstablished && config.reconnect.isEnabled {
			sessionEstablished = false
			isReconnecting = true
			state = .reconnecting
			startupContinuation?.finish()
			emit(.lost(reason: reason))
			if debug {
				print("\(Date().description) \t ⚠️ Connection lost (\(reason)), reconnecting")
			}
			reconnectTask = Task { [weak self] in
				await self?.reconnectLoop(reason: reason)
			}
			return
		}
		
		// Never fully up, or reconnecting is off: the old behavior, the stream ends.
		if sessionEstablished {
			sessionEstablished = false
			emit(.lost(reason: reason))
		}
		state = .disconnected
		messageContinuation?.finish()
		startupContinuation?.finish()
	}
	
	/// Retries until the API is up again, the policy gives up, or `disconnect()` cancels it.
	private func reconnectLoop(reason: String) async {
		var attempt = 0
		var lastReason = reason
		
		while !Task.isCancelled {
			attempt += 1
			if let limit = config.reconnect.maxAttempts, attempt > limit {
				await giveUp(attempts: limit, reason: lastReason)
				return
			}
			
			let delay = config.reconnect.delay(forAttempt: attempt)
			await emitOnLoop(.reconnecting(attempt: attempt, after: delay))
			do {
				try await Task.sleep(for: .seconds(delay))
			} catch {
				return
			}
			
			do {
				try await onEventLoop {
					guard !self.userClosed else { throw ConnectionError.disconnected }
					self.prepareAttempt()
				}
				try await establishSession()
				if Task.isCancelled { throw ConnectionError.disconnected }
				try await onEventLoop {
					guard !self.userClosed else { throw ConnectionError.disconnected }
					// The socket may have dropped again while the attempt finished.
					guard self.isConnected else { throw ConnectionError.connectionLost }
					self.isReconnecting = false
					self.sessionEstablished = true
					self.reconnectTask = nil
					self.emit(.connected(reconnect: true))
				}
				if debug {
					print("\(Date().description) \t ✅ Reconnected after \(attempt) attempt(s)")
				}
				return
			} catch {
				lastReason = Connection.describe(error)
				if debug {
					print("\(Date().description) \t ⚠️ Reconnect attempt \(attempt) failed: \(lastReason)")
				}
				await abandonAttempt()
			}
		}
	}
	
	/// The policy is exhausted: tell the consumer and end the stream.
	private func giveUp(attempts: Int, reason: String) async {
		try? await onEventLoop {
			self.isReconnecting = false
			self.sessionEstablished = false
			self.reconnectTask = nil
			self.state = .failed(.connectionFailed(reason))
			self.emit(.reconnectFailed(attempts: attempts, reason: reason))
			self.messageContinuation?.finish()
			self.startupContinuation?.finish()
		}
	}
	
	private static func describe(_ error: Error) -> String {
		if let localized = error as? LocalizedError, let text = localized.errorDescription {
			return text
		}
		return String(describing: error)
	}
	
	// MARK: - connection & farm status
	
	public enum FarmStatus: Sendable {
		case unknown
		case ok
		case disconnected
		case inactive
	}

	public enum ConnectionStatus: Sendable {
		case unknown
		case lost
		case restored(dataLost: Bool)
		case portReset(newPort: Int?)
	}

	/// Last link status seen. Written on the event loop and not synchronized for readers on other
	/// threads: consume `Response.status` from `messages()` instead of polling this.
	public private(set) var connectionStatus: ConnectionStatus = .unknown

	public struct ServiceStatus: Sendable {
		public var marketDataFarm: FarmStatus = .unknown
		public var historicalFarm: FarmStatus = .unknown
		public var securityDefinitionFarm: FarmStatus = .unknown
	}

	/// Last farm status seen. Same caveat as `connectionStatus`.
	public private(set) var serviceStatus = ServiceStatus()
	
	/// Keeps `connectionStatus` and `serviceStatus` in step with the notices.
	private func apply(_ event: ConnectionEvent) {
		assertEventLoop()
		
		switch event {
		case .gatewayOffline:
			connectionStatus = .lost
		
		case .gatewayOnline(let dataLost):
			connectionStatus = .restored(dataLost: dataLost)
		
		case .portReset(let newPort):
			connectionStatus = .portReset(newPort: newPort)
		
		case .farm(let farm, let status, _):
			switch farm {
			case .marketData:
				serviceStatus.marketDataFarm = status
			case .historical:
				serviceStatus.historicalFarm = status
			case .securityDefinition:
				serviceStatus.securityDefinitionFarm = status
			}
		
		default:
			break
		}
	}
	
	/// Puts a status event into the message stream, in order with the data around it.
	private func emit(_ event: ConnectionEvent) {
		assertEventLoop()
		messageContinuation?.yield(.status(event))
	}
	
	private func emitOnLoop(_ event: ConnectionEvent) async {
		try? await onEventLoop { self.emit(event) }
	}

	
	// MARK: - Message Sending
	
	public func sendRequest(_ request: any Request) async throws {
		
		//print(request)
		
		let payloadBytes = try request.serializedData()
		let msgId  = request.type.protoRawValue
		let frameLen = Int32(4 + payloadBytes.count)
		
		try await onEventLoopFuture {
			
			guard self.isConnected, let channel = self.channel
			else { throw ConnectionError.notConnected }
			
			var buffer = channel.allocator.buffer(capacity: 4 + 4 + payloadBytes.count)
			buffer.writeInteger(frameLen)
			buffer.writeInteger(msgId)
			buffer.writeBytes(payloadBytes)
			return channel.writeAndFlush(buffer)
		}
	}
	
	private func writeData(_ data:Data) async throws{
		try await onEventLoopFuture {
			guard let channel = self.channel else {
				throw ConnectionError.notConnected
			}
			return channel.writeAndFlush(data)
		}
	}
	
	
	// MARK: - Message Receiving
	
	/// The one stream of everything the gateway sends and of the link `Response.status` events.
	/// It lives across reconnects and ends on `disconnect()`, when the policy gave up
	/// (after `.reconnectFailed`), or, with reconnecting off, when the socket is lost.
	public func messages() -> AsyncStream<Response> {
		messageStream ?? AsyncStream { _ in }
	}
	
	// MARK: - Private Helpers
	
	private func handleInboundMessage(_ response: Response) {
		assertEventLoop()
		
		if case .error(let id, let code, let message) = response {

			if id < 0 {
				// Not tied to a request: connectivity and farm notices, or a connection-level error.
				let event = ConnectionEvent.fromNotice(code: code, message: message)
				apply(event)
				emit(event)
			} else {
				messageContinuation?.yield(response)
			}

		} else if case .nextOrderID(let orderID) = response {

			// Order IDs are client-managed and must stay strictly increasing, so
			// this is the single place that updates the counter — on every
			// occurrence, not just during startup — and it's never surfaced on
			// the public stream. Callers always go through `nextOrderID()`.
			// The counter never moves backwards: after a reconnect the gateway may
			// answer with a lower id than one already handed out.
			nextValidOrderID = max(nextValidOrderID ?? orderID, orderID)
			startupContinuation?.yield(response)

		} else {

			messageContinuation?.yield(response)
			startupContinuation?.yield(response)

		}
	}
	
	private func handleInboundError(_ error: Error) {
		assertEventLoop()
		if debug{
			print("\(Date().description) \t ⚠️ Handler error: \(error)")
		}
		state = .failed(.networkError(error))
	}
	
	private func handleConnectionState(_ state: ConnectionHandler.ConnectionState) {
		assertEventLoop()
		switch state {
		case .connected:
			isConnected = true
			switch self.state {
			case .idle, .tcpConnecting:
				self.state = .tcpConnected
			default:
				break
			}
		case .disconnected:
			connectionDropped(reason: "connection closed")
		case .error(let error):
			if debug {
				print("\(Date().description) \t ⚠️ Connection error: \(error)")
			}
			connectionDropped(reason: Connection.describe(error))
		}
	}
	
	public func setServerVersion(_ version: Int) {
		if eventLoop.inEventLoop {
			self.serverVersion = version
		} else {
			eventLoop.execute { [weak self] in
				self?.serverVersion = version
			}
		}
	}
	
	/// The next order ID TWS considers valid. Per IB's contract, order IDs are
	/// client-managed and must be strictly increasing — this is seeded from
	/// the `nextValidId` callback and kept current by `handleInboundMessage`
	/// intercepting every subsequent `.nextOrderID` message (e.g. from a later
	/// `reqIds()` resync or from a reconnect), so `nextOrderID()` is always the single source of truth.
	/// It only ever moves up.
	/// This is unrelated to generic `reqId`s (market data, contract details, ...),
	/// which callers are free to choose and reuse without going through Connection.
	private var nextValidOrderID: Int32? = nil

	public func nextOrderID() async throws -> Int32 {
		try await onEventLoop {
			guard let current = self.nextValidOrderID else {
				throw ConnectionError.notConnected
			}
			defer { self.nextValidOrderID = current + 1 }
			return current
		}
	}
}


extension Connection {
	
	func performHandshake(on channel: Channel) async throws {

		let lowerBound = config.acceptedVersions.lowerBound.rawValue
		let upperBound = config.acceptedVersions.upperBound.rawValue
		var payloadString = "v\(lowerBound)..\(upperBound)"
		if let options = config.options, !options.isEmpty {
			payloadString += " \(options)"
		}
		let payload = Data(payloadString.utf8)
		
		var buffer = channel.allocator.buffer(capacity: 4 + 4 + payload.count)
		buffer.writeBytes(Array("API\0".utf8))
		buffer.writeInteger(Int32(payload.count))
		buffer.writeBytes(payload)
		
		let promise = channel.eventLoop.makePromise(of: HandshakeResponse.self)
		try await onEventLoop {
			self.state = .handshakeSent
			self.handshakePromise = promise
			if let pending = self.pendingHandshakeResult {
				self.pendingHandshakeResult = nil
				self.completeHandshake(pending)
			}
		}
		
		// Send raw handshake
		_ = try await onEventLoopFuture { [buffer] in channel.writeAndFlush(buffer) }
		
		if debug {
			print("\(Date().description) \t 📤 Sent handshake")
		}
		
		let response = try await promise.futureResult.get()
		try await onEventLoop {
			self.serverVersion = response.serverVersion
			self.connectionTime = response.connectionTime
			
			if self.serverVersion < lowerBound {
				throw ConnectionError.serverVersionTooOld(self.serverVersion, minimum: lowerBound)
			}
			if self.serverVersion > upperBound {
				throw ConnectionError.unsupportedServerVersion(self.serverVersion)
			}
			
			self.state = .handshakeComplete
		}
		
	}

	private func handleHandshakeResponse(_ result: Result<HandshakeResponse, Error>, generation gen: Int) {
		assertEventLoop()
		guard gen == generation else { return }
		if handshakePromise == nil {
			pendingHandshakeResult = result
			return
		}
		completeHandshake(result)
	}
	
	private func completeHandshake(_ result: Result<HandshakeResponse, Error>) {
		assertEventLoop()
		//print(result)
		guard let promise = handshakePromise else { return }
		handshakePromise = nil
		switch result {
		case .success(let response):
			promise.succeed(response)
		case .failure(let error):
			promise.fail(error)
		}
	}

	func sendStartAPI() async throws {
		var request = IBPBStartApiRequest()
		request.clientID = id
		if let capabilities = config.capabilities{
			request.optionalCapabilities = capabilities
		}
		try await sendRequest(request)
	}

}
