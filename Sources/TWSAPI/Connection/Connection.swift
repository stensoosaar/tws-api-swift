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
	
	@inline(__always)
	private func assertEventLoop() {
		assert(eventLoop.inEventLoop, "Connection state must be accessed on the EventLoop.")
	}
	 
	
	// MARK: - Connection Management
	
	public func connect() async throws {
		try await beginConnecting()
		let bootstrap = try await makeBootstrap()

		do {
			let channel = try await establishTCPConnection(using: bootstrap)

			try await performHandshake(on: channel)
			try await installProtobufPipeline(on: channel)
			try await onEventLoop { self.isConnected = true }

			try await startApiAndAwaitReady()
			try await onEventLoop { self.state = .apiStarted }

			let connectedServerVersion = try await onEventLoop { self.serverVersion }
			if debug{
				print("\(Date().description) \t ✅ Connected to IB API (server \(connectedServerVersion.debugDescription))")
			}

		} catch {
			if debug{
				print("\(Date().description) \t ❌ Connection failed: \(error)")
			}
			try? await onEventLoop {
				self.state = .failed(.connectionFailed(error.localizedDescription))
				self.isConnected = false
			}
			throw ConnectionError.connectionFailed(error.localizedDescription)
		}
	}

	/// Guards against a duplicate connect, flips state to `.tcpConnecting`,
	/// and prepares the message streams consumed once messages start flowing.
	private func beginConnecting() async throws {
		try await onEventLoop {
			guard !self.isConnected else {
				throw ConnectionError.alreadyConnected
			}
			self.state = .tcpConnecting
		}

		if debug{
			print("🔌 Connecting to \(config.host):\(config.port)...")
		}

		let (stream, continuation) = AsyncStream<Response>.makeStream()
		let (startupStream, startupContinuation) = AsyncStream<Response>.makeStream()
		try await onEventLoop {
			self.messageStream = stream
			self.messageContinuation = continuation
			self.startupStream = startupStream
			self.startupContinuation = startupContinuation
		}
	}

	/// Builds the NIO bootstrap with the frame decoder + handshake handler
	/// installed. The handshake handler is stashed on `self` here since
	/// `installProtobufPipeline` needs to remove it later.
	private func makeBootstrap() async throws -> ClientBootstrap {
		let handshakeHandler = HandshakeHandler { [weak self] result in
			guard let self else { return }
			if self.eventLoop.inEventLoop {
				self.handleHandshakeResponse(result)
			} else {
				self.eventLoop.execute { self.handleHandshakeResponse(result) }
			}
		}
		try await onEventLoop { self.handshakeHandler = handshakeHandler }

		return ClientBootstrap(group: eventLoopGroup)
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
			guard self.isConnected else { return false }
			self.state = .disconnecting
			return true
		}
		guard shouldDisconnect else { return }
		if debug{
			print("Disconnecting \(id)...")
		}
		
		try await onEventLoop {
			self.messageContinuation?.finish()
			self.messageContinuation = nil
			self.startupContinuation?.finish()
			self.startupContinuation = nil
		}
		
		let channel = try await onEventLoop { self.channel }
		_ = try await onEventLoopFuture {
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
		}
		if debug{
			print("\(Date().description) \t \(id) Disconnected")
		}
	}

	
	private func installProtobufPipeline(on channel: Channel) async throws {
		// Remove the handshake handler now that the version negotiation is done.
		let handshakeHandler = try await onEventLoop { self.handshakeHandler }
		if let handshakeHandler {
			try await channel.pipeline.removeHandler(handshakeHandler).get()
			try await onEventLoop { self.handshakeHandler = nil }
		}
	
	   // let pacingHandler = ResponsePacingHandler(interval: .milliseconds(20))
	
		let connectionHandler = ConnectionHandler(
			messageHandler: { [weak self] message in
				guard let self else { return }
				if self.eventLoop.inEventLoop {
					self.handleInboundMessage(message)
				} else {
					self.eventLoop.execute { self.handleInboundMessage(message) }
				}
			},
			errorHandler: { [weak self] error in
				guard let self else { return }
				if self.eventLoop.inEventLoop {
					self.handleInboundError(error)
				} else {
					self.eventLoop.execute { self.handleInboundError(error) }
				}
			},
			connectionStateHandler: { [weak self] state in
				guard let self else { return }
				if self.eventLoop.inEventLoop {
					self.handleConnectionState(state)
				} else {
					self.eventLoop.execute { self.handleConnectionState(state) }
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
				managedAccounts = identifiers

			case .nextOrderID:
				hasNextOrderID = true

			case .error(let id, let code, let message):
				guard id == -1 else {break}
				updateServiceStatus(code: code, message: message)
			
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

	public private(set) var connectionStatus: ConnectionStatus = .unknown

	public struct ServiceStatus: Sendable {
		public var marketDataFarm: FarmStatus = .unknown
		public var historicalFarm: FarmStatus = .unknown
		public var securityDefinitionFarm: FarmStatus = .unknown
	}

	public private(set) var serviceStatus = ServiceStatus()
	
	private func updateServiceStatus(code: Int32, message: String) {
		assertEventLoop()
							
		switch code {
		case 1100:
			connectionStatus = .lost
		
		case 1101:
			connectionStatus = .restored(dataLost: true)
		
		case 1102:
			connectionStatus = .restored(dataLost: false)
		
		case 1300:
			let newValue = message
				.split(whereSeparator: { !$0.isNumber })
				.compactMap { Int($0) }.last
			connectionStatus = .portReset(newPort: newValue)
		
		case 2103:
			serviceStatus.marketDataFarm = .disconnected
		
		case 2104:
			serviceStatus.marketDataFarm = .ok
		
		case 2108:
			serviceStatus.marketDataFarm = .inactive
		
		case 2105:
			serviceStatus.historicalFarm = .disconnected
		
		case 2106:
			serviceStatus.historicalFarm = .ok
		
		case 2107:
			serviceStatus.historicalFarm = .inactive
		
		case 2158:
			serviceStatus.securityDefinitionFarm = .ok
		
		default:
			break
		}
	
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
	
	public func messages() -> AsyncStream<Response> {
		messageStream ?? AsyncStream { _ in }
	}
	
	// MARK: - Private Helpers
	
	private func handleInboundMessage(_ response: Response) {
		assertEventLoop()
		
		if case .error(let id, let code, let message) = response {

			if id < 0 {
				updateServiceStatus(code: code, message: message)
			} else {
				messageContinuation?.yield(response)
			}

		} else if case .nextOrderID(let orderID) = response {

			// Order IDs are client-managed and must stay strictly increasing, so
			// this is the single place that updates the counter — on every
			// occurrence, not just during startup — and it's never surfaced on
			// the public stream. Callers always go through `nextOrderID()`.
			nextValidOrderID = orderID
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
			isConnected = false
			self.state = .disconnected
			messageContinuation?.finish()
			startupContinuation?.finish()
		case .error(let error):
			if debug {
				print("\(Date().description) \t ⚠️ Connection error: \(error)")
			}
			isConnected = false
			self.state = .failed(.networkError(error))
			messageContinuation?.finish()
			startupContinuation?.finish()
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
	/// client-managed and must be strictly increasing — this is seeded once from
	/// the `nextValidId` callback and kept current by `handleInboundMessage`
	/// intercepting every subsequent `.nextOrderID` message (e.g. from a later
	/// `reqIds()` resync), so `nextOrderID()` is always the single source of truth.
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

	private func handleHandshakeResponse(_ result: Result<HandshakeResponse, Error>) {
		assertEventLoop()
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
