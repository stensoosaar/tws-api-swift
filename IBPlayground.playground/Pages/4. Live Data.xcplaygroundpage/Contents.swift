/*:
 [􀄪 Historical Data](3.%20Historical%20Data)
# Live Market Data

  Subscribe to real-time Level 1 tick streams across active instruments. Bid, Ask, Last Price, Volume are provided by default, additional tags ara available here

  Managing Data Streams
  * **Context Buffering**: Save outgoing `IBPBMarketDataRequest` structs by `reqID`. As continuous `.marketData` events arrive through `api.messages()`, look up the matching `reqID` in your buffer to evaluate which symbol/exchange emitted the tick payload.
  * **Unsubscribing**: Market data subscriptions stay active on TWS until you explicitly cancel them. Send an `IBPBCancelMarketData` request with the same `reqID` before breaking out of the loop — simply stopping your local loop or cancelling the `Task` does not free the subscription on TWS's side, and it will keep counting against your market data line limit.
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
	
	var request = IBPBMarketDataRequest()
	request.reqID = try await api.nextOrderID()
	request.contract = q
	
	try await api.sendRequest(request)
	
	var responseCount: Int = 0
	messageLoop: for try await response in api.messages(){
		
		switch response {

		case .marketData(let id, let payload):
			print(payload)
			responseCount += 1
			guard responseCount < 150 else {
				var cancellation = IBPBCancelMarketData()
				cancellation.reqID = request.reqID
				try await api.sendRequest(cancellation)
				break messageLoop
			}
			
		case .error(let id, let code, let message):
			print("->%@:€@ for %d", code, message, id)
			break messageLoop
		
		default:
			print("->\(response)")
		}
		
	}
	
	print("completed")

}


//: [􀄫 Account Updates](5.%20Account%20Updates)
