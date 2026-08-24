//
//  MarketDataType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//

public enum MarketDataType: Int32, Sendable, Codable{
	/**
	 Live market data
	 
	 streaming data relayed back in real time.
	- important:
	 Market data subscriptions are required to receive live market data.
	 */
	case realtime = 1
	
	/**
	 Last data recorded at market close.
	 
	 When you set the market data type to Frozen, you are asking TWS to send
	 the last available quote when there is not one currently available.
	 
	 For instance, if a market is currently closed and real time data is requested,
	 nil values will commonly be returned for the bid and ask prices to indicate there
	 is no current bid/ask data available.
	 
	 To receive the last know bid/ask price before the market close, switch to
	 market data type 2 from the API before requesting market data.
	 */
	case frozen = 2
	
	/**
	 15 - 20 minutes delayed data
		 
	 If live data is available a request for delayed data would be ignored by TWS.
	 Delayed market data is returned with delayed Tick Types.
	 
	 - note: available without market data subscriptions.
	 */
	case delayed = 3
	
	/**
	 Last data (delayed for 15-20min) recorded at market close.
	 
	 - note: available without market data subscriptions.
	 */
	case delayedFrozen = 4
}


extension MarketDataType: CustomStringConvertible {
	public var description: String {
		switch self {
		case .realtime: 		return "REALTIME"
		case .frozen:			return "FROZEN"
		case .delayed: 			return "DELAYED"
		case .delayedFrozen: 	return "DElAYED FROZEN"
		}
	}
}


