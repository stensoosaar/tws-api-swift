//
//  ResponsePacingHandler.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 07.06.2026.
//




import NIOCore


final class ResponsePacingHandler: ChannelInboundHandler, @unchecked Sendable {
	typealias InboundIn = Response
	typealias InboundOut = Response

	private let interval: TimeAmount
	private var queue: [Response] = []
	private var scheduled: Scheduled<Void>?
	private var nextSendDeadline: NIODeadline?
	private var context: ChannelHandlerContext?

	init(interval: TimeAmount) {
		self.interval = interval
	}

	func handlerAdded(context: ChannelHandlerContext) {
		self.context = context
	}

	func channelRead(context: ChannelHandlerContext, data: NIOAny) {
		queue.append(unwrapInboundIn(data))
		scheduleIfNeeded(context: context)
	}

	func channelInactive(context: ChannelHandlerContext) {
		scheduled?.cancel()
		scheduled = nil
		queue.removeAll(keepingCapacity: false)
		nextSendDeadline = nil
		self.context = nil
		context.fireChannelInactive()
	}

	private func scheduleIfNeeded(context: ChannelHandlerContext) {
		guard scheduled == nil else { return }
		let now = context.eventLoop.now
		let deadline = max(nextSendDeadline ?? now, now)
		let delay = deadline - now

		scheduled = context.eventLoop.scheduleTask(in: delay) { [weak self] in
			self?.scheduledFire()
		}
	}

	private func scheduledFire() {
		guard let context else { return }
		scheduled = nil
		flushOne(context: context)
	}

	private func flushOne(context: ChannelHandlerContext) {
		guard !queue.isEmpty else { return }
		let message = queue.removeFirst()
		context.fireChannelRead(self.wrapInboundOut(message))

		let now = context.eventLoop.now
		nextSendDeadline = now + interval

		if !queue.isEmpty {
			scheduleIfNeeded(context: context)
		}
	}
}
