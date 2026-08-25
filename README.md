# Interactive Brokers TWS API swiftified
An open-source Swift library for the Interactive Brokers Trader Workstation (TWS) API. 
This software is not an official product and is not affiliated with or endorsed by Interactive Brokers.

[![License](https://img.shields.io/badge/license-GPL%203.0-blue.svg?style=flat)](https://github.com/stensoosaar/tws-api-swift#license)
![Swift](https://img.shields.io/badge/swift-6.3-blue.svg)
![macOS 26+](https://img.shields.io/badge/macOS-26.0%2B-blue.svg)
![Version 10.49](https://img.shields.io/badge/Version-10.49-blue.svg)

## Motivation
The official TWS API has long been available in C++, Java, and Python. While Swift offers an excellent balance of performance, safety, and developer experience, it lacks first-class support. This library aims to fill that gap.

## Overview
The library provides a Swift interface to the Interactive Brokers TWS API, built on SwiftNIO and Swift Concurrency, allowing you to request/subscribe:
- Account information
- Contract definitions
- Real-time market data (top of book and order book)
- Historical data
- Order placement and management
- Market scanners
- Wall Street Horizon Corporate Events 

## License
This project includes protobuf messages generated from Interactive Brokers LLC's official schema and is licensed under GPL-3.0-or-later, matching Interactive Brokers' own API license.

## Key Features & Differences
- Uses Swift structs that closely mirror the official API’s protobuf-style objects.
- Requests are represented as **structs** instead of client methods — making them easier to store, serialize, and match with responses.
- Responses are delivered via **AsyncStream** rather than callbacks.
- Market data is unified into a single `TickEvent` enum (instead of separate `TickPrice`, `TickSize`, `TickGeneric`, and `TickString` callbacks).
- `TickByTick` data follows the same structure as `HistoricalTick`, providing convenient access to `Last`, `MidPoint`, and `BidAsk` types.

## Requirements
- [IB Gateway](https://www.interactivebrokers.com/en/trading/ibgateway-stable.php) or TWS
- Swift 6.3+
- macOS 26.0+ (should also work on Linux but not yet tested)

## Installation
Add package to your SwiftPM project:
```swift
// swift-tools-version:6.3
import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        .package(url: "https://github.com/stensoosaar/tws-api-swift.git", .branch("main"))
    ],
    targets: [
        .target(
            name: "MyTarget",
            dependencies: [
                .product(name: "TWSAPI", package: "tws-api-swift")
            ]
        )
    ]
)
```

## Usage
``` Swift
let conf = Connection.Configuration(
	host: "127.0.0.1",
	port: 4002,
	capabilities: nil,
	options: nil
)

let api = Connection(id: 100, with: conf)

Task{
	
	do{
		try await api.connect()
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
		switch response {
		case .contractDetails(let id, let contract, let details):
			print(contract)
			print(details)

		case .contractDetailsEnd(let id):
			break messageLoop
			
		case .error(let id, let code, let message):
			break messageLoop
			
		default:
			break
		}
	}
	
	try await api.disconnect()
}
```
See included IBPlayground (will add more samples soon)
