//
//  ReconnectPolicy.swift
//  tws-api-swift
//

import Foundation

/// How `Connection` re-establishes the socket after the gateway or TWS drops it.
///
/// Delays grow geometrically from `initialDelay` and are capped at `maxDelay`. The attempt
/// counter restarts for every outage, so `maxAttempts` bounds one outage, not the lifetime of
/// the connection. When the limit is reached the connection emits
/// `ConnectionEvent.reconnectFailed` and its message stream finishes.
public struct ReconnectPolicy: Sendable, Equatable, Codable {

	/// Attempts per outage before giving up. `nil` retries forever, `0` never reconnects.
	public var maxAttempts: Int?

	/// Wait before the first attempt, in seconds.
	public var initialDelay: TimeInterval

	/// Upper bound for the wait between two attempts, in seconds.
	public var maxDelay: TimeInterval

	/// Growth factor between consecutive waits.
	public var multiplier: Double

	public init(
		maxAttempts: Int? = nil,
		initialDelay: TimeInterval = 1,
		maxDelay: TimeInterval = 30,
		multiplier: Double = 2
	) {
		self.maxAttempts = maxAttempts
		self.initialDelay = initialDelay
		self.maxDelay = maxDelay
		self.multiplier = multiplier
	}

	/// Retry forever, 1s, 2s, 4s ... capped at 30s.
	public static let `default` = ReconnectPolicy()

	/// Never reconnect: a lost socket ends the message stream, as it did before reconnect existed.
	public static let disabled = ReconnectPolicy(maxAttempts: 0)

	public var isEnabled: Bool {
		if let maxAttempts { return maxAttempts > 0 }
		return true
	}

	/// The wait before the given attempt (1-based).
	public func delay(forAttempt attempt: Int) -> TimeInterval {
		let exponent = Double(max(attempt, 1) - 1)
		let raw = initialDelay * pow(multiplier, exponent)
		return min(maxDelay, max(0, raw))
	}
}
