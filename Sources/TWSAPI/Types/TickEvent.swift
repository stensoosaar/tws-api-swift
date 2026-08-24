//
//  TickEvent.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//

import Foundation

public enum TickEvent: Sendable{
	
	//tick price values
	case BidPrice(Double)
	case DelayedBid(Double)
	case AskPrice(Double)
	case DelayedAsk(Double)
	case LastPrice(Double)
	case DelayedLast(Double)
	case BidYield(Double)
	case AskYield(Double)
	case LastYield(Double)
	case DelayedYieldBid(Double)
	case DelayedYieldAsk(Double)
	case ETFNavBid(Double)
	case ETFNavAsk(Double)
	case ETFNavLast(Double)
	case DelayedBidOption(Double)
	case DelayedAskOption(Double)
	case DelayedLastOption(Double)

	case OpenPrice(Double)
	case HighPrice(Double)
	case LowPrice(Double)
	case ClosePrice(Double)
	case DelayedOpenPrice(Double)
	case DelayedHighPrice(Double)
	case DelayedLowPrice(Double)
	case DelayedClosePrice(Double)

	case Low13Weeks(Double)
	case High13Weeks(Double)
	case Low26Weeks(Double)
	case High26Weeks(Double)
	case Low52Weeks(Double)
	case High52Weeks(Double)

	case AuctionPrice(Double)
	case MarkPrice(Double)
	case LastRTHTrade(Double)
	case CreditmanMarkPrice(Double)
	case CreditmanSlowMarkPrice(Double)
	case DelayedModelOption(Double)
	case ETFNavPriorClose(Double)
	case ETFNavFrozenLast(Double)
	case ETFNavHigh(Double)
	case ETFNavLow(Double)
	case ETFNavClose(Double)
	
	//tick size values
	case BidSize(Double)
	case DelayedBidSize(Double)
	case AskSize(Double)
	case DelayedAskSize(Double)
	case LastSize(Double)
	case DelayedLastSize(Double)
	case Volume(Double)
	case AverageVolume(Double)
	case DelayedVolume(Double)
	case OpenInterest(Double)
	case OptionCallOpenInterest(Double)
	case OptionPutOpenInterest(Double)
	case OptionCallVolume(Double)
	case OptionPutVolume(Double)
	case AuctionVolume(Double)
	case AuctionImbalance(Double)
	case RegulatoryImbalance(Double)
	case ShortTermVolume3Minutes(Double)
	case ShortTermVolume5Minutes(Double)
	case ShortTermVolume10Minutes(Double)
	case FuturesOpenInterest(Double)
	case AverageOptionVolume(Double)
	case ShortableShares(Double)
	
	//tick string values
	case News(String)
	case Dividends(paid: Double, expected: Double, nextDate: String?, nextAmount: Double?)
	case RTVolumeTimeSales(price: String, size: String, timestamp: String, volume: String, vwap: String, single: String)
	case LastTimestamp(TimeInterval)
	case LastRegulatoryTime(TimeInterval)
	case DelayedLastTimestamp(TimeInterval)
	case LastExchange(String)
	case OptionBidExchange(String)
	case OptionAskExchange(String)
	case BidExchange(String)
	case AskExchange(String)
	
	// tick generic values
	case OptionImpliedVolatility(Double)
	case OptionHistoricalVolatility(Double)
	case IndexFuturePremium(Double)
	case Shortable(ShortingAvailability)
	case Halted(TradingStatus)
	case TradeCount(Double)
	case TradeRate(Double)
	case VolumeRate(Double)
	case RTHistoricalVolatility(Double)
	case BondFactorMultiplier(Double)
	case EstimatedIPOMidpoint(Double)
	case FinalIPOPrice(Double)
	
}
