//
//  MessageFrameDecoder.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 07.06.2026.
//



import NIOCore
import Foundation

final class MessageFrameDecoder: ByteToMessageDecoder {

    typealias InboundOut = ByteBuffer

    private enum State {
        case waitingForLength
        case waitingForPayload(length: Int)
    }

    private var state: State = .waitingForLength

    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        switch state {
        case .waitingForLength:
            guard buffer.readableBytes >= 4 else { return .needMoreData }

            guard let length = buffer.getInteger(at: buffer.readerIndex, as: Int32.self) else {
                throw ConnectionError.invalidMessageFormat
            }

            let payloadLength = Int(length)
            guard payloadLength > 0 && payloadLength < 10_000_000 else {
                throw ConnectionError.invalidMessageFormat
            }

            buffer.moveReaderIndex(forwardBy: 4)
            state = .waitingForPayload(length: payloadLength)
            return .continue

        case .waitingForPayload(let length):
            guard buffer.readableBytes >= length else { return .needMoreData }

            guard let payloadBuffer = buffer.readSlice(length: length) else {
                throw ConnectionError.invalidMessageFormat
            }

            state = .waitingForLength
            context.fireChannelRead(self.wrapInboundOut(payloadBuffer))
            return .continue
        }
    }

    func decodeLast(context: ChannelHandlerContext, buffer: inout ByteBuffer, seenEOF: Bool) throws -> DecodingState {
        guard buffer.readableBytes > 0 else { return .needMoreData }
        return try decode(context: context, buffer: &buffer)
    }
}
