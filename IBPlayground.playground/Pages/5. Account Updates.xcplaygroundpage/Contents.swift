/*:
 [􀄪 Live Data](4.%20Live%20Data)
 # Account Updates
 Track live portfolio balances, active positions, and real-time Profit & Loss (PnL) metrics.

  Snapshot Mechanics & Real-Time Streaming
  * **Initial Snapshot vs. Continuous Stream**: When you request account updates or positions, TWS API first transmits a full initial snapshot in a rapid burst of individual messages.
  * **Completion Markers**: The end of this initial dump is signaled by `.accountUpdateEnd` (or `.positionSizeEnd`). After this marker fires, TWS switches to continuous streaming mode — emitting real-time individual update messages as balances, margin values, or positions change.
  * **Batch Buffering**: Because updates arrive as single-message fragments, accumulate incoming key-value state (`.accountUpdate`) in a local buffer and flush/render your UI when the initial end marker arrives, or during discrete update cycles.
  * **PnL Context Resolution**: Streaming account PnL messages (`.accountPNL`) carry real-time values but omit explicit account metadata — map incoming `reqID`s against your stored `IBPBPnLRequest` instances in `requestBuffer` to trace updates back to their account. Per-position PnL works the same way but needs its own subscription per contract (`IBPBPnLSingleRequest`), matched via `.positionPNL` — not requested in this demo.

  Execution Workflow
  1. **Discovery**: Intercept `.managedAccounts` to retrieve active account IDs.
  2. **Dispatch & Track**: Send targeted requests (`IBPBAccountUpdatesMultiRequest`, `IBPBPnLRequest`, `IBPBPositionsMultiRequest`) and index their `reqID` in `requestBuffer`.
  3. **Snapshot & Stream**: Collect individual key-value fields into a buffer until `.accountUpdateEnd` signals the completion of the initial state. Subsequent individual messages then update that buffered state live.
  */

import Foundation
import TWSAPI

import PlaygroundSupport
let page = PlaygroundPage.current
page.needsIndefiniteExecution = true


let conf = Connection.Configuration(
	host: "127.0.0.1",
	port: 4002
)

let api = Connection(id: 100, with: conf)


Task{
	
	do {
		try await api.connect()
	} catch {
		print(error)
	}
		
	var requestBuffer:[Int32: any Request] = [:]
	
	messageLoop: for try await response in api.messages(){
		
		switch response {

		case .managedAccounts(let identifiers):
			for id in identifiers{
				
				var updateRequest = IBPBAccountUpdatesMultiRequest()
				updateRequest.reqID = try await api.nextOrderID()
				updateRequest.account = id
				try await api.sendRequest(updateRequest)
				requestBuffer[updateRequest.reqID] = updateRequest
				
				var accountPNLRequest = IBPBPnLRequest()
				accountPNLRequest.reqID = try await api.nextOrderID()
				accountPNLRequest.account = id
				try await api.sendRequest(accountPNLRequest)
				requestBuffer[accountPNLRequest.reqID] = accountPNLRequest
				
				var positionSizeRequest = IBPBPositionsMultiRequest()
				positionSizeRequest.reqID = try await api.nextOrderID()
				positionSizeRequest.account = id
				try await api.sendRequest(positionSizeRequest)
				requestBuffer[positionSizeRequest.reqID] = positionSizeRequest

			}
			
		case .accountUpdateTime(let time):
			print("Account updated at \(time)")
			
		case .accountUpdate(let id, let payload):
			print(payload)
			
		case .accountUpdateEnd(let id):
			guard let request = requestBuffer[id] as? IBPBAccountUpdatesMultiRequest else { break }
			print("initial update completed for \(request.account)")
						
		case .positionSize(let id, let payload):
			print(payload)
			
			
		case .positionSizeEnd(let id):
			print(String(repeating: "*", count: 80))
			print("positions loaded")
			print(String(repeating: "*", count: 80))
			
		case .accountPNL(let id, let payload):
			guard let request = requestBuffer[id] as? IBPBPnLRequest else { break }
			print("Account PNL for \(request.account)\n", payload)
			
		case .positionPNL(let id, let payload):
			guard let request = requestBuffer[id] as? IBPBPnLSingleRequest else { break }
			print("\(request.conID) @ \(request.account)\n", payload)

		case .error(let id, let code, let message):
			print("->%@:€@ for %d", code, message, id)
			break messageLoop
		
		default:
			print("->\(response)")
		}
		
	}
	
}
