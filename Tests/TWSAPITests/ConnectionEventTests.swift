import Testing
@testable import TWSAPI

@Suite("ConnectionEvent notices")
struct ConnectionEventTests {

	@Test("1100, 1101 and 1102 are the gateway's link to IB")
	func connectivity() {
		#expect(ConnectionEvent.fromNotice(code: 1100, message: "Connectivity between IB and Trader Workstation has been lost.") == .gatewayOffline)
		#expect(ConnectionEvent.fromNotice(code: 1101, message: "restored, data lost") == .gatewayOnline(dataLost: true))
		#expect(ConnectionEvent.fromNotice(code: 1102, message: "restored, data maintained") == .gatewayOnline(dataLost: false))
	}

	@Test("1300 carries the new port")
	func portReset() {
		let event = ConnectionEvent.fromNotice(
			code: 1300,
			message: "TWS socket port has been reset and this connection is being dropped. Please reconnect on the new port - 7497"
		)
		#expect(event == .portReset(newPort: 7497))
		#expect(ConnectionEvent.fromNotice(code: 1300, message: "no digits here") == .portReset(newPort: nil))
	}

	@Test("market data farm notices")
	func marketDataFarm() {
		#expect(ConnectionEvent.fromNotice(code: 2103, message: "Market data farm connection is broken:usfarm")
			== .farm(.marketData, .disconnected, name: "usfarm"))
		#expect(ConnectionEvent.fromNotice(code: 2104, message: "Market data farm connection is OK:usfarm")
			== .farm(.marketData, .ok, name: "usfarm"))
		#expect(ConnectionEvent.fromNotice(code: 2108, message: "Market data farm connection is inactive but should be available upon demand.usfarm")
			== .farm(.marketData, .inactive, name: ""))
	}

	@Test("historical farm notices")
	func historicalFarm() {
		#expect(ConnectionEvent.fromNotice(code: 2105, message: "HMDS data farm connection is broken:ushmds")
			== .farm(.historical, .disconnected, name: "ushmds"))
		#expect(ConnectionEvent.fromNotice(code: 2106, message: "HMDS data farm connection is OK:ushmds")
			== .farm(.historical, .ok, name: "ushmds"))
		#expect(ConnectionEvent.fromNotice(code: 2107, message: "HMDS data farm connection is inactive but should be available upon demand.ushmds")
			== .farm(.historical, .inactive, name: ""))
	}

	@Test("security definition farm notices, including the broken one")
	func secDefFarm() {
		#expect(ConnectionEvent.fromNotice(code: 2157, message: "Sec-def data farm connection is broken:secdefnj")
			== .farm(.securityDefinition, .disconnected, name: "secdefnj"))
		#expect(ConnectionEvent.fromNotice(code: 2158, message: "Sec-def data farm connection is OK:secdefnj")
			== .farm(.securityDefinition, .ok, name: "secdefnj"))
	}

	@Test("anything else stays a plain notice")
	func other() {
		#expect(ConnectionEvent.fromNotice(code: 2119, message: "Market data farm is connecting:usfarm")
			== .notice(code: 2119, message: "Market data farm is connecting:usfarm"))
		#expect(ConnectionEvent.fromNotice(code: 326, message: "Unable to connect as the client id is already in use.")
			== .notice(code: 326, message: "Unable to connect as the client id is already in use."))
	}

	@Test("the farm name is what follows the last colon")
	func farmName() {
		#expect(ConnectionEvent.farmName(in: "Market data farm connection is OK:usfarm.us") == "usfarm.us")
		#expect(ConnectionEvent.farmName(in: "a: b :  eufarm ") == "eufarm")
		#expect(ConnectionEvent.farmName(in: "no colon") == "")
	}

	@Test("events print readably")
	func description() {
		#expect(ConnectionEvent.connected(reconnect: true).description == "connected (reconnected)")
		#expect(ConnectionEvent.gatewayOnline(dataLost: true).description.contains("data lost"))
	}
}
