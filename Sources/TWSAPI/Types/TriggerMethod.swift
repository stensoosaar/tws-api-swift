//
//  TriggerMethod.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum TriggerMethod: Int32, Codable, Sendable {
	
	/**
	 Default behavior:
	 - For OTC stocks and US options: uses the "double bid/ask" method.
	 - For all other instruments: uses the "last" price method.
	 */
	case `default` = 0
	
	/// trigger based on two consecutive bid or ask prices.
	case doubleBidAsk = 1
	
	/// trigger based on the last traded price.
	case last = 2
	
	/// Utriggers on two consecutive last prices.
	case doubleLast = 3
	
	///  triggers on a single bid or ask.
	case bidAsk = 4
	
	/// triggers on either the last price or a bid/ask update.
	case lastOrBidAsk = 7
	
	/// triggers based on the mid-point between bid and ask.
	case midPoint = 8
	
}
