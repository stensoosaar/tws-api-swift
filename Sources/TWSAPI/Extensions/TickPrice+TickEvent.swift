//
//  TickPriceType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//

import TWSModels


extension IBPBTickPrice: IBAPIConvertible {
	
	typealias ConversionResult = Response
	
	enum TickPriceType: Int32 {
		case bidPrice = 1
		case askPrice = 2
		case lastPrice = 4
		case delayedBid = 66
		case delayedAsk = 67
		case delayedLast = 68
		case bidYield = 50
		case askYield = 51
		case lastYield = 52
		case delayedYieldBid = 103
		case delayedYieldAsk = 104
		case openPrice = 14
		case highPrice = 6
		case lowPrice = 7
		case closePrice = 9
		case delayedOpen = 76
		case delayedHigh = 72
		case delayedLow = 73
		case delayedClose = 75
		case low13Week = 15
		case high13Week = 16
		case low26Week = 17
		case high26Week = 18
		case low52Week = 19
		case high52Week = 20
		case auctionPrice = 35
		case markPrice = 37
		case lastRTHTrade = 57
		case delayedModelOption = 83
		case creditmanMarkPrice = 78
		case creditmanSlowMarkPrice = 79
		case etfNavPriorClose = 93
		case etfNavClose = 92
		case etfNavBid = 94
		case etfNavAsk = 95
		case etfNavLast = 96
		case etfFrozenNavLast = 97
		case etfNavHigh = 98
		case etfNavLow = 99
		case delayedBidOption = 80
		case delayedAskOption = 81
		case delayedLastOption = 82

	}

	func convert() throws -> Response {
		
		guard let type = TickPriceType(rawValue: tickType) else {
			throw CodingError.failedToDecode("tick price type from \(tickType)")
		}
		
		var value: TickEvent
		
		switch type {
		case .bidPrice:
			value = .BidPrice(price)
		case .askPrice:
			value = .AskPrice(price)
		case .lastPrice:
			value = .LastPrice(price)
		case .delayedBid:
			value = .DelayedBid(price)
		case .delayedAsk:
			value = .DelayedAsk(price)
		case .delayedLast:
			value = .DelayedLast(price)
		case .bidYield:
			value = .BidYield(price)
		case .askYield:
			value = .AskYield(price)
		case .lastYield:
			value = .LastYield(price)
		case .delayedYieldBid:
			value = .DelayedYieldBid(price)
		case .delayedYieldAsk:
			value = .DelayedYieldAsk(price)
		case .openPrice:
			value = .OpenPrice(price)
		case .highPrice:
			value = .HighPrice(price)
		case .lowPrice:
			value = .LowPrice(price)
		case .closePrice:
			value = .ClosePrice(price)
		case .delayedOpen:
			value = .DelayedOpenPrice(price)
		case .delayedHigh:
			value = .DelayedHighPrice(price)
		case .delayedLow:
			value = .DelayedLowPrice(price)
		case .delayedClose:
			value = .DelayedClosePrice(price)
		case .low13Week:
			value = .Low13Weeks(price)
		case .high13Week:
			value = .High13Weeks(price)
		case .low26Week:
			value = .Low26Weeks(price)
		case .high26Week:
			value = .High26Weeks(price)
		case .low52Week:
			value = .Low52Weeks(price)
		case .high52Week:
			value = .High52Weeks(price)
		case .auctionPrice:
			value = .AuctionPrice(price)
		case .markPrice:
			value = .MarkPrice(price)
		case .lastRTHTrade:
			value = .LastRTHTrade(price)
		case .delayedModelOption:
			value = .DelayedModelOption(price)
		case .creditmanMarkPrice:
			value = .CreditmanMarkPrice(price)
		case .creditmanSlowMarkPrice:
			value = .CreditmanSlowMarkPrice(price)
		case .etfNavPriorClose:
			value = .ETFNavPriorClose(price)
		case .etfNavClose:
			value = .ETFNavClose(price)
		case .etfNavBid:
			value = .ETFNavBid(price)
		case .etfNavAsk:
			value = .ETFNavAsk(price)
		case .etfNavLast:
			value = .ETFNavLast(price)
		case .etfFrozenNavLast:
			value = .ETFNavFrozenLast(price)
		case .etfNavHigh:
			value = .ETFNavHigh(price)
		case .etfNavLow:
			value = .ETFNavLow(price)
		case .delayedBidOption:
			value = .DelayedBidOption(price)
		case .delayedAskOption:
			value = .DelayedAskOption(price)
		case .delayedLastOption:
			value = .DelayedLastOption(price)
		}
		
		return Response.marketData(requestID: reqID, payload: value)
		
	}
	
}


