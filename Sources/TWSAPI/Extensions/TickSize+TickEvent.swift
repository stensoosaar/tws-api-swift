//
//  TickSizeType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//

import TWSModels

extension IBPBTickSize: IBAPIConvertible {
	
	typealias ConversionResult = Response

	enum TickSizeType: Int32 {
		case bidSize = 0
		case askSize = 3
		case lastSize = 5
		case delayedBidSize = 69
		case delayedAskSize = 70
		case delayedLastSize = 71
		case volume = 8
		case delayedVolume = 74
		case avgVolume = 21
		case openInterest = 22
		case optionCallOpenInterest = 27
		case optionPutOpenInterest = 28
		case optionCallVolume = 29
		case optionPutVolume = 30
		case auctionVolume = 34
		case auctionImbalance = 36
		case regulatoryImbalance = 61
		case shortTermVolume3Min = 63
		case shortTermVolume5Min = 64
		case shortTermVolume10Min = 65
		case futuresOpenInterest = 86
		case avgOptVolume = 87
		case shortableShares = 89
	}
	
	func convert() throws -> Response {
		
		guard let type = TickSizeType(rawValue: tickType) else {
			throw CodingError.failedToDecode("tick price type from \(tickType)")
		}
		
		var payload: TickEvent
		let value = Double(size) ?? 0
		
		switch type {
		case .bidSize:
			payload = .BidSize(value)
		case .askSize:
			payload = .AskSize(value)
		case .lastSize:
			payload = .LastSize(value)
		case .delayedBidSize:
			payload = .DelayedBidSize(value)
		case .delayedAskSize:
			payload = .DelayedAskSize(value)
		case .delayedLastSize:
			payload = .DelayedLastSize(value)
		case .volume:
			payload = .Volume(value)
		case .delayedVolume:
			payload = .DelayedVolume(value)
		case .avgVolume:
			payload = .AverageVolume(value)
		case .openInterest:
			payload = .OpenInterest(value)
		case .optionCallOpenInterest:
			payload = .OptionCallOpenInterest(value)
		case .optionPutOpenInterest:
			payload = .OptionPutOpenInterest(value)
		case .optionCallVolume:
			payload = .OptionCallVolume(value)
		case .optionPutVolume:
			payload = .OptionPutVolume(value)
		case .auctionVolume:
			payload = .AuctionVolume(value)
		case .auctionImbalance:
			payload = .AuctionImbalance(value)
		case .regulatoryImbalance:
			payload = .RegulatoryImbalance(value)
		case .shortTermVolume3Min:
			payload = .ShortTermVolume3Minutes(value)
		case .shortTermVolume5Min:
			payload = .ShortTermVolume5Minutes(value)
		case .shortTermVolume10Min:
			payload = .ShortTermVolume10Minutes(value)
		case .futuresOpenInterest:
			payload = .FuturesOpenInterest(value)
		case .avgOptVolume:
			payload = .AverageOptionVolume(value)
		case .shortableShares:
			payload = .ShortableShares(value)
		}
		
		return Response.marketData(requestID: reqID, payload: payload)
		
	}
	
}
