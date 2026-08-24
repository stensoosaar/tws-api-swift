//
//  ConnectionError.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 07.06.2026.
//


import Foundation



public enum ConnectionError: Error, Sendable {
    // Connection errors
    case notConnected
    case alreadyConnected
    case connectionFailed(String)
    case connectionLost
    case disconnected
    
    // Protocol errors
    case unsupportedServerVersion(Int?)
    case serverVersionTooOld(Int?, minimum: Int)
    case invalidServerResponse
    case handshakeFailed(String)
    
    // Message errors
    case encodingFailed(String)
    case decodingFailed(String)
    case invalidMessageFormat
    case unknownMessageType(Int32)
    
    // Request errors
    case invalidRequest(String)
    case requestTimeout(Int32)
    case serverError(code: Int, message: String)
    
    // Network errors
    case networkError(Error)
    case writeError(Error)
    case readError(Error)
}


extension ConnectionError: LocalizedError {
    public var errorDescription: String? {
		switch self {
		case .notConnected:
			return "Not connected to IB Gateway/TWS"
			
		case .alreadyConnected:
			return "Already connected to IB Gateway/TWS"
			
		case .connectionFailed(let reason):
			return "Connection failed: \(reason)"
			
		case .connectionLost:
			return "Connection lost"
			
		case .disconnected:
			return "Disconnected from server"
			
		case .unsupportedServerVersion(let version):
			return "Server version \(version?.description ?? "-") is not supported"
			
		case .serverVersionTooOld(let version, let minimum):
			return "Server version \(version?.description ?? "-") is too old. Minimum required: \(minimum)"
			
		case .invalidServerResponse:
			return "Invalid response from server"
			
		case .handshakeFailed(let reason):
			return "Handshake failed: \(reason)"
			
		case .encodingFailed(let details):
			return "Message encoding failed: \(details)"
			
		case .decodingFailed(let details):
			return "Message decoding failed: \(details)"
			
		case .invalidMessageFormat:
			return "Invalid message format"
			
		case .unknownMessageType(let msgId):
			return "Unknown message type: \(msgId)"
			
		case .invalidRequest(let details):
			return "Invalid request: \(details)"
			
		case .requestTimeout(let reqId):
			return "Request timeout for ID: \(reqId)"
			
		case .serverError(let code, let message):
			return "Server error [\(code)]: \(message)"
			
		case .networkError(let error):
			return "Network error: \(error.localizedDescription)"
			
		case .writeError(let error):
			return "Write error: \(error.localizedDescription)"
			
		case .readError(let error):
			return "Read error: \(error.localizedDescription)"
			
		}
    }
}
