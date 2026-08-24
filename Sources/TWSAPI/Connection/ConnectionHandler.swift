//
//  IBConnectionHandler.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 16.02.2026.
//


import NIOCore
import Foundation


final class ConnectionHandler: ChannelInboundHandler, Sendable {
	
	typealias InboundIn = Response
	
	private let messageHandler: @Sendable (Response) -> Void
	private let errorHandler: @Sendable (Error) -> Void
	private let connectionStateHandler: @Sendable (ConnectionState) -> Void
	
	enum ConnectionState: Sendable {
		case connected
		case disconnected
		case error(Error)
	}
	
	init(
		messageHandler: @escaping @Sendable (Response) -> Void,
		errorHandler: @escaping @Sendable (Error) -> Void,
		connectionStateHandler: @escaping @Sendable (ConnectionState) -> Void
	) {
		self.messageHandler = messageHandler
		self.errorHandler = errorHandler
		self.connectionStateHandler = connectionStateHandler
	}
	
	func channelActive(context: ChannelHandlerContext) {
		print("\(Date()) \t ✅ Channel active")
		connectionStateHandler(.connected)
	}
	
	func channelInactive(context: ChannelHandlerContext) {
		print("\(Date()) \t ❌ Channel inactive")
		connectionStateHandler(.disconnected)
	}
	
	func channelRead(context: ChannelHandlerContext, data: NIOAny) {
		let message = unwrapInboundIn(data)
		messageHandler(message)
	}
	
	func errorCaught(context: ChannelHandlerContext, error: Error) {
		print("⚠️ Error caught: \(error)")
		errorHandler(error)
		connectionStateHandler(.error(error))
		context.close(promise: nil)
	}
}
