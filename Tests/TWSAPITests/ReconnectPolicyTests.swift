import Testing
@testable import TWSAPI

@Suite("ReconnectPolicy")
struct ReconnectPolicyTests {

	@Test("default waits 1s, 2s, 4s ... and stays at the 30s cap")
	func backoff() {
		let policy = ReconnectPolicy.default
		let delays = (1...8).map { policy.delay(forAttempt: $0) }
		#expect(delays == [1, 2, 4, 8, 16, 30, 30, 30])
	}

	@Test("a huge attempt number does not overflow")
	func noOverflow() {
		#expect(ReconnectPolicy.default.delay(forAttempt: 100_000) == 30)
	}

	@Test("attempt numbers below one count as the first")
	func firstAttempt() {
		#expect(ReconnectPolicy.default.delay(forAttempt: 0) == 1)
		#expect(ReconnectPolicy.default.delay(forAttempt: -3) == 1)
	}

	@Test("an initial delay above the cap is cut to the cap")
	func capWins() {
		let policy = ReconnectPolicy(initialDelay: 60, maxDelay: 5)
		#expect(policy.delay(forAttempt: 1) == 5)
	}

	@Test("default retries forever, disabled never, a limit is enabled")
	func enabled() {
		#expect(ReconnectPolicy.default.isEnabled)
		#expect(ReconnectPolicy.default.maxAttempts == nil)
		#expect(!ReconnectPolicy.disabled.isEnabled)
		#expect(ReconnectPolicy(maxAttempts: 3).isEnabled)
	}

	@Test("configuration carries the policy and keeps the default")
	func configuration() {
		let plain = Connection.Configuration(host: "127.0.0.1", port: 4002)
		#expect(plain.reconnect == .default)
		let off = Connection.Configuration(host: "127.0.0.1", port: 4002, reconnect: .disabled)
		#expect(off.reconnect == .disabled)
		let tiny = Connection.Configuration(host: "127.0.0.1", port: 4002, connectTimeout: 0)
		#expect(tiny.connectTimeout == 1)
	}
}
