/*:
[􀄪 Contracts](2.%20Contracts)
# Historical Data
Request historical OHLCV bar series and stream live bar updates using customizable intervals and bar sizes.

  Multi-Subscription Context Tracking
  Incoming `.historicBars` and `.historicalBarUpdate` events return payload arrays tagged with a `reqID`. Store your outgoing `IBPBHistoricalDataRequest` instances in a request dictionary keyed by `reqID` — and when a response arrives, check its `id` against that dictionary before acting on it. This matters as soon as more than one historical data request is active at once: without that check, a handler has no way to tell which request a given message belongs to.

  Modes
  * **Batch Window**: Specify a fixed `DateInterval` to pull static past performance.
  * **Continuous Streaming**: Leave the interval open-ended to first receive historical context, followed by live incoming bar updates (`.historicalBarUpdate`). This relies on IBKR's `keepUpToDate` mode, which requires an unset end date — confirm your open-ended `DateInterval` maps to that, rather than a literal far-future timestamp.

  Choosing a Lookback Period
  Size your `DateInterval` and bar size together so a single request returns a few thousand bars at most, not tens of thousands — a fixed lookback that works for daily bars can be far too large once you switch to 1-minute bars.

  Bar Source
  For forex, index, and CFD contracts, request `.midpoint` rather than `.trades` — these instruments have no centralized last-trade tape, so `TRADES` bars aren't meaningful for them.

  - Note: Pacing Limits
  Historical data requests are rate-limited: avoid identical requests within 15 seconds, avoid six or more requests for the same contract/exchange/tick type within 2 seconds, and stay under 60 requests in any 10-minute window (`.bidAsk` requests count double). Check IBKR Campus for the current cap on simultaneous open historical data requests before relying on a specific number — it's subject to change.
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

var q = IBPBContract()
q.type = .stock
q.idType = IDType.ric
q.secID = "AAPL.OQ"
q.exchange = "SMART"
q.currency = "USD"


Task{
	
	do {
		try await api.connect()
	} catch {
		print(error)
	}
	
	var request = IBPBHistoricalDataRequest()
	request.reqID = try await api.nextOrderID()
	request.contract = q
	request.dateInterval = DateInterval.lookback(1, unit: .month)
	request.barSizeSetting = BarSize.hour1.rawValue
	request.whatToShow = BarSource.trades.rawValue
	
	try await api.sendRequest(request)
	
	messageLoop: for try await response in api.messages(){
		
		switch response {

		case .historicBars(let id, let payload):
			payload.forEach({print($0)})
		
		case .historicalBarsEnd(let id):
			break messageLoop
			
		case .error(let id, let code, let message):
			print("->%@:€@ for %d", code, message, id)
			break messageLoop
		
		default:
			print("->\(response)")
		}
		
	}
	
	print("task 1 completed")

}

/*:
## Historical data + updates
Runs alongside the batch request above as a second, concurrent subscription — wait for the initial connection to be established before sending this request, and filter incoming messages by this request's own `reqID` so its bars and updates aren't mixed up with the batch request's.
*/
Task{
	
	try await Task.sleep(nanoseconds: 1_000_000_000)
	
	var request = IBPBHistoricalDataRequest()
	request.reqID = try await api.nextOrderID()
	request.contract = q
	request.dateInterval = DateInterval.lookback(1, unit: .day, until: .distantFuture)
	request.barSizeSetting = BarSize.hour1.rawValue
	request.whatToShow = BarSource.trades.rawValue
	
	try await api.sendRequest(request)
	
	var receivedUpdates: Int = 0
	messageLoop: for try await response in api.messages(){
		
		switch response {

		case .historicBars(let id, let payload):
			payload.forEach({print($0)})
		
		case .historicalBarsEnd(let id):
			print("historical data loaded")
			
		case .historicalBarUpdate(let requestID, let payload):
			print(payload)
			receivedUpdates += 1
			guard receivedUpdates < 10 else {
				break messageLoop
			}
			
		case .error(let id, let code, let message):
			print("->%@:€@ for %d", code, message, id)
			break messageLoop
		
		default:
			print("->\(response)")
		}
		
	}
	
	try await api.disconnect()
	print("task 2 completed")
	page.finishExecution()

}

//: [􀄫 Live Data](4.%20Live%20Data)
