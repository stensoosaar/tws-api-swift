//
//  HandshakeResponse.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 07.06.2026.
//


import NIOCore
import NIOConcurrencyHelpers
import Foundation

struct HandshakeResponse: Sendable {
	let serverVersion: Int
	let connectionTime: String
}

final class HandshakeHandler: ChannelInboundHandler, RemovableChannelHandler, Sendable {
	typealias InboundIn = ByteBuffer
	
	private let responseHandler: @Sendable (Result<HandshakeResponse, Error>) -> Void
	private let didHandle = NIOLockedValueBox(false)
	
	init(responseHandler: @escaping @Sendable (Result<HandshakeResponse, Error>) -> Void) {
		self.responseHandler = responseHandler
	}
	
	func channelRead(context: ChannelHandlerContext, data: NIOAny) {
		let shouldHandle = didHandle.withLockedValue { handled -> Bool in
			if handled { return false }
			handled = true
			return true
		}
		guard shouldHandle else { return }
		
		var buffer = unwrapInboundIn(data)
		guard let payload = buffer.readData(length: buffer.readableBytes) else {
			responseHandler(.failure(ConnectionError.invalidServerResponse))
			context.close(promise: nil)
			return
		}
		
		let bytes = [UInt8](payload)
		let nullSeparated = bytes.split(separator: 0)
		if nullSeparated.count >= 1 {
			let versionToken = String(decoding: nullSeparated[0], as: UTF8.self)
			let versionString = versionToken.hasPrefix("v") ? String(versionToken.dropFirst()) : versionToken
			guard let serverVersion = Int(versionString) else {
				responseHandler(.failure(ConnectionError.invalidServerResponse))
				context.close(promise: nil)
				return
			}
			let connectionTime = nullSeparated.count > 1
				? String(decoding: nullSeparated[1], as: UTF8.self)
				: ""
			responseHandler(.success(HandshakeResponse(serverVersion: serverVersion, connectionTime: connectionTime)))
			return
		}
		
		let response = String(decoding: bytes, as: UTF8.self)
		let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
		let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
		
		guard let versionToken = parts.first else {
			responseHandler(.failure(ConnectionError.invalidServerResponse))
			context.close(promise: nil)
			return
		}
		
		let versionString: Substring
		if versionToken.hasPrefix("v") {
			versionString = versionToken.dropFirst()
		} else {
			versionString = versionToken
		}
		
		guard let serverVersion = Int(versionString) else {
			responseHandler(.failure(ConnectionError.invalidServerResponse))
			context.close(promise: nil)
			return
		}
		
		let connectionTime = parts.count > 1 ? String(parts[1]) : ""
		responseHandler(.success(HandshakeResponse(serverVersion: serverVersion, connectionTime: connectionTime)))
	}
	
	func errorCaught(context: ChannelHandlerContext, error: Error) {
		responseHandler(.failure(error))
		context.close(promise: nil)
	}
}
