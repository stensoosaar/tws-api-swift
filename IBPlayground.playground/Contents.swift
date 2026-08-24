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


