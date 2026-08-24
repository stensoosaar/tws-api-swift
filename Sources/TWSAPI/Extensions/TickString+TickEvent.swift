//
//  TickStringType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//

import TWSModels


extension IBPBTickString: IBAPIConvertible {
	
	typealias ConversionResult = Response

	enum TickStringType: Int32{
		case news = 62
		case ibDividends = 59
		case rtVolume = 48
		case rtTradeVolume = 77
		case lastRegTime = 85
		case lastTimestamp = 45
		case delayedLastTimestamp = 88
		case optionBidExch = 25
		case optionAskExch = 26
		case lastExch = 84
		case bidExch = 32
		case askExch = 33
	}
	
	func convert() throws -> Response {
		
		guard let type = TickStringType(rawValue: tickType) else {
			throw CodingError.failedToDecode("tick price type from \(tickType)")
		}
		
		var payload: TickEvent
		
		switch type {
		case .news:
			payload = parseNews(from: value)
		case .ibDividends:
			payload = parseDividends(from: value)
		case .rtVolume, .rtTradeVolume:
			payload = parseRTVolume(from: value)
		case .lastRegTime:
			let timeInterval = Double(value) ?? 0
			payload = .LastRegulatoryTime(timeInterval)
		case .lastTimestamp:
			let timeInterval = Double(value) ?? 0
			payload = .LastTimestamp(timeInterval)
		case .delayedLastTimestamp:
			let timeInterval = Double(value) ?? 0
			payload = .DelayedLastTimestamp(timeInterval)
		case .optionBidExch:
			payload = .OptionBidExchange(value)
		case .optionAskExch:
			payload = .OptionAskExchange(value)
		case .lastExch:
			payload = .LastExchange(value)
		case .bidExch:
			payload = .BidExchange(value)
		case .askExch:
			payload = .AskExchange(value)
		}

		return Response.marketData(requestID: reqID, payload: payload)
		
	}
	
	private func parseRTVolume(from text: String) -> TickEvent{
		
		let components = text
			.components(separatedBy: ",")
			.filter{$0.count == 6}
		
		let price = components[0]
		let size = components[1]
		let timestamp = components[2]
		let totalVolume = components[3]
		let vwap = components[4]
		let singleTrade = components[5]
		
		return TickEvent.RTVolumeTimeSales(
			price: price,
			size: size,
			timestamp: timestamp,
			volume: totalVolume,
			vwap: vwap,
			single: singleTrade
		)

	}
	
	private func parseNews(from text: String) -> TickEvent{
		return TickEvent.News(text)
	}

	private func parseDividends(from text: String) -> TickEvent{

		let components = text
			.components(separatedBy: ",")
			.filter{$0.count == 4}
		
		let paid = Double(components[0]) ?? 0
		let expected = Double(components[1]) ?? 0
		let nextDate =  components[2]
		let nextAmount = Double(components[3])
		
		return .Dividends(paid: paid, expected: expected, nextDate: nextDate, nextAmount: nextAmount)
		
	}
	
}
