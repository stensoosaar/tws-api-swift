//
//  TickGenericType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//


import TWSModels


extension IBPBTickGeneric: IBAPIConvertible {
	
	typealias ConversionResult = Response

	enum TickGenericType: Int32 {
		case tradeCount = 54
		case tradeRate = 55
		case volumeRate = 56
		case halted = 49
		case estimatedIPOMidpoint = 101
		case finalIPOLast = 102
		case shortable = 46
		case rtHistoricalVol = 58
		case optionImpliedVol = 24
		case optionHistoricalVol = 23
		case indexFuturePremium = 31
		case bondFactorMultiplier = 60

	}
	
	func convert() throws -> Response {
		
		guard let type = TickGenericType(rawValue: tickType) else {
			throw CodingError.failedToDecode("tick price type from \(tickType)")
		}
		
		var payload: TickEvent

		switch type {
		case .tradeCount:
			payload = .TradeCount(value)
		case .tradeRate:
			payload = .TradeRate(value)
		case .volumeRate:
			payload = .VolumeRate(value)
		case .halted:
			let status = TradingStatus(rawValue: value) ?? .unknown
			return Response.marketData(requestID: reqID, payload: .Halted(status))
		case .estimatedIPOMidpoint:
			payload = .EstimatedIPOMidpoint(value)
		case .finalIPOLast:
			payload = .FinalIPOPrice(value)
		case .shortable:
			let status = parseShortableValue(value)
			return Response.marketData(requestID: reqID, payload: .Shortable(status))
		case .rtHistoricalVol:
			payload = .RTHistoricalVolatility(value)
		case .optionImpliedVol:
			payload = .OptionImpliedVolatility(value)
		case .optionHistoricalVol:
			payload = .OptionHistoricalVolatility(value)
		case .indexFuturePremium:
			payload = .IndexFuturePremium(value)
		case .bondFactorMultiplier:
			payload = .BondFactorMultiplier(value)
		}
		
		return Response.marketData(requestID: reqID, payload: payload)

	}

	private func parseShortableValue(_ value: Double) -> ShortingAvailability{
		switch value {
		case 0...1.5: 	return .notShortable
		case 1.5...2.5: return .locatable
		default:		return .shortable
		}
	}
	
	
}
