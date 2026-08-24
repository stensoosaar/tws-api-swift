//
//  HedgeType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum HedgeType: String, Codable, Sendable {
	
	/// Delta hedge — typically used to maintain a neutral delta position.
	case delta 				= "D"
	
	/// Beta hedge — used to hedge against beta exposure in a portfolio.
	case beta 				= "B"
	
	/// FX hedge — used to hedge foreign exchange risk.
	case fx			 		= "F"
	
	/// Pair hedge — used in pair trading strategies.
	case pair 				= "P"
}
