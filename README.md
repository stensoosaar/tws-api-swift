# tws-api-swift — Interactive Brokers TWS API for Swift

An open-source Swift library for the Interactive Brokers Trader Workstation (TWS) API.

[![License](https://img.shields.io/badge/license-GPL%203.0-blue.svg?style=flat)](https://github.com/stensoosaar/tws-api-swift#license)
![Swift](https://img.shields.io/badge/swift-6.3-blue.svg)
![macOS 26+](https://img.shields.io/badge/macOS-26.0%2B-blue.svg)
![Version 10.47](https://img.shields.io/badge/Version-10.49-blue.svg)

> **Note**: This software is **not** an official product and is not affiliated with or endorsed by Interactive Brokers.

## Overview
IBKit provides a modern, Swift-native interface to the Interactive Brokers TWS API, allowing you to programmatically access:
- Account information
- Contract definitions
- Real-time market data (top of book and order book)
- Historical data
- Order placement and management

## Motivation
The official TWS API has long been available in C++, Java, and Python. While Swift offers an excellent balance of performance, safety, and developer experience, it lacks first-class support. This library aims to fill that gap.

## Conformance
IBKit is compatible with **TWS API version 10.49**.

## License
This project includes protobuf message definitions generated from Interactive Brokers LLC's official .proto schema and is licensed under GPL-3.0-or-later as is
Intaractive Broker's own license

## Key Features & Differences
- Uses Swift structs that closely mirror the official API’s protobuf-style objects.
- Requests are represented as **structs** instead of client methods — making them easier to store, serialize, and match with responses.
- Responses are delivered via **AsyncStream** rather than callbacks.
- Market data is unified into a single `TickEvent` enum (instead of separate `TickPrice`, `TickSize`, `TickGeneric`, and `TickString` callbacks).
- `TickByTick` data follows the same structure as `HistoricalTick`, providing convenient access to `Last`, `MidPoint`, and `BidAsk` types.

## Requirements

- [IB Gateway](https://www.interactivebrokers.com/en/trading/ibgateway-stable.php) or TWS
- macOS 26.0+
- Swift 6.3+
- Xcode 26.0+

## Installation

Add IBKit to your SwiftPM project:

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

## Usage
See IBPlayground
