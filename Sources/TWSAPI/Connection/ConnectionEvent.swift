//
//  ConnectionEvent.swift
//  tws-api-swift
//

import Foundation

public extension Connection {

	/// The data farms a gateway reports on.
	enum Farm: Sendable {
		case marketData
		case historical
		case securityDefinition
	}
}

/// A change in the state of the link between this client, the gateway and the IB farms.
///
/// Events travel in-band: `Connection.messages()` yields them as `Response.status(_:)`, in order
/// with the data and execution messages around them, and the same stream survives reconnects.
///
/// Two different outages are told apart on purpose:
/// - the *socket* to the gateway/TWS broke: `lost`, then `reconnecting`, then `connected(reconnect: true)`.
///   The gateway process restarted or the network dropped, so everything the client had
///   subscribed to is gone and must be requested again.
/// - the *gateway lost its own link to IB*: `gatewayOffline`, then `gatewayOnline(dataLost:)`.
///   The socket stays up; only market data (when `dataLost`) needs to be requested again.
public enum ConnectionEvent: Sendable, Equatable {

	/// The API is ready: handshake done, managed accounts and next order id received.
	/// `reconnect` is `false` for the first connect and `true` after a lost socket was re-established.
	case connected(reconnect: Bool)

	/// The socket to the gateway/TWS was lost. If the policy allows it, `reconnecting` follows.
	case lost(reason: String)

	/// A reconnect attempt `attempt` (1-based, per outage) starts after waiting `after` seconds.
	case reconnecting(attempt: Int, after: TimeInterval)

	/// The reconnect policy was exhausted. The message stream finishes after this event.
	case reconnectFailed(attempts: Int, reason: String)

	/// Notice 1100: the gateway lost its connection to IB. The socket is still open.
	case gatewayOffline

	/// Notices 1101 and 1102: the gateway's link to IB is back. With `dataLost`, market data
	/// subscriptions were dropped and have to be requested again (1101); otherwise they are intact (1102).
	case gatewayOnline(dataLost: Bool)

	/// Notice 1300: the gateway's socket port was changed and this connection is being dropped.
	case portReset(newPort: Int?)

	/// Notices 2103-2108 and 2157-2158: a data farm connection changed. `name` is the farm
	/// named in the message (for example "usfarm"), empty when the message names none.
	case farm(Connection.Farm, Connection.FarmStatus, name: String)

	/// Any other notice that is not tied to a request (error id below zero), as is.
	case notice(code: Int32, message: String)
}

extension ConnectionEvent: CustomStringConvertible {

	public var description: String {
		switch self {
		case .connected(let reconnect):
			return reconnect ? "connected (reconnected)" : "connected"
		case .lost(let reason):
			return "connection lost: \(reason)"
		case .reconnecting(let attempt, let after):
			return "reconnecting, attempt \(attempt) in \(after)s"
		case .reconnectFailed(let attempts, let reason):
			return "reconnect gave up after \(attempts) attempts: \(reason)"
		case .gatewayOffline:
			return "gateway lost its connection to IB"
		case .gatewayOnline(let dataLost):
			return dataLost ? "gateway link to IB restored, data lost" : "gateway link to IB restored, data maintained"
		case .portReset(let port):
			return "gateway port reset" + (port.map { " (new port \($0))" } ?? "")
		case .farm(let farm, let status, let name):
			return "\(farm) farm \(name) \(status)"
		case .notice(let code, let message):
			return "notice \(code): \(message)"
		}
	}
}

extension ConnectionEvent {

	/// Classifies a notice that is not tied to a request (error id below zero).
	static func fromNotice(code: Int32, message: String) -> ConnectionEvent {
		switch code {
		case 1100:
			return .gatewayOffline
		case 1101:
			return .gatewayOnline(dataLost: true)
		case 1102:
			return .gatewayOnline(dataLost: false)
		case 1300:
			let newPort = message
				.split(whereSeparator: { !$0.isNumber })
				.compactMap { Int($0) }.last
			return .portReset(newPort: newPort)
		case 2103:
			return .farm(.marketData, .disconnected, name: farmName(in: message))
		case 2104:
			return .farm(.marketData, .ok, name: farmName(in: message))
		case 2108:
			return .farm(.marketData, .inactive, name: farmName(in: message))
		case 2105:
			return .farm(.historical, .disconnected, name: farmName(in: message))
		case 2106:
			return .farm(.historical, .ok, name: farmName(in: message))
		case 2107:
			return .farm(.historical, .inactive, name: farmName(in: message))
		case 2157:
			return .farm(.securityDefinition, .disconnected, name: farmName(in: message))
		case 2158:
			return .farm(.securityDefinition, .ok, name: farmName(in: message))
		default:
			return .notice(code: code, message: message)
		}
	}

	/// IB writes "Market data farm connection is OK:usfarm": the farm is what follows the last colon.
	static func farmName(in message: String) -> String {
		guard let colon = message.lastIndex(of: ":") else { return "" }
		return String(message[message.index(after: colon)...]).trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
