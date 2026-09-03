/*:
 [􀄪 Welcome](1.%20Welcome)
# Contracts
 An `IBPBContract` struct is **dual-mode**:

 - **As a query** (what you send): loosely specify identifying attributes — Symbol/Type/Currency, or an external ID (ISIN, CUSIP, FIGI, RIC) — and TWS resolves it against its database. How many matches come back depends on how narrow your query is. Too little identifying data and TWS returns an error rather than a match; a tightly-specified query resolves to exactly one contract, a loose one can return several.
 - **As a pointer** (what you get back): once a contract comes back from the server — via `contractDetails`, or by referencing its `conId` — it's fully resolved. From that point on, treat it as a precise reference, not something that needs further searching.

 **Dispatch**: send an `IBPBContractDataRequest`. TWS replies with matching `IBPBContract`/`IBPBContractDetails` pairs until `.contractDetailsEnd`.

 **Tip**: resolve your trading universe once, at session warmup — request contract details for everything you plan to trade, and hold onto the resolved (pointer-mode) contracts for the rest of the session, rather than re-running queries for every market data or order request.
 */

import Foundation
import TWSAPI

import PlaygroundSupport
let page = PlaygroundPage.current
page.needsIndefiniteExecution = true


let conf = Connection.Configuration(
	host: "127.0.0.1",
	port: 4002,
	capabilities: nil,
	options: nil
)

let api = Connection(id: 100, with: conf)


Task{
	
	do{
		print("connecting")
		try await api.connect()
		print("ok")
	} catch {
		print(error)
	}
	
	
	var q = IBPBContract()
	q.type = .stock
	q.idType = IDType.ric
	q.secID = "AAPL.OQ"
	q.exchange = "SMART"
	q.currency = "USD"
	
	var request = IBPBContractDataRequest()
	request.reqID = try await api.nextOrderID()
	request.contract = q
	
	try await api.sendRequest(request)
	
	messageLoop: for try await response in api.messages(){
		
		print(api.serviceStatus)
		
		switch response {
		case .contractDetails(let id, let contract, let details):
			
			
			print("\n\n")
			print(contract)
			print(details)
			print(String(repeating: "-", count: 80))

		case .contractDetailsEnd(let id):
			print("->contract details delivered for \(id)")
			break messageLoop
			
		case .error(let id, let code, let message):
			print("->%@:€@ for %d", code, message, id)
			break messageLoop
			
		default:
			print("->\(response)")
		}
		
	}
	
	try await api.disconnect()
	print("task completed")
	page.finishExecution()

}

//: [􀄫 Historical Data](3.%20Historical%20Data)
