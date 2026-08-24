//
//  WhatToShow.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum WhatToShow: String, Sendable,Codable {
	case TRADES = "TRADES"
	case MIDPOINT = "MIDPOINT"
	case BID = "BID"
	case ASK = "ASK"
	case BID_ASK = "BID_ASK"
	case HISTORICAL_VOLATILITY = "HISTORICAL_VOLATILITY"
	case OPTION_IMPLIED_VOLATILITY = "OPTION_IMPLIED_VOLATILITY"
	case YIELD_ASK = "YIELD_ASK"
	case YIELD_BID = "YIELD_BID"
	case YIELD_BID_ASK = "YIELD_BID_ASK"
	case YIELD_LAST = "YIELD_LAST"
	case ADJUSTED_LAST = "ADJUSTED_LAST"
	case SCHEDULE = "SCHEDULE"
	case AGGTRADES = "AGGTRADES"
}
