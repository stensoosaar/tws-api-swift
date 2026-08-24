//
//  TradingStatus.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//


public enum TradingStatus: Double, Sendable {
	
	/// Status not available. Usually returned with frozen data.
	case unknown = -1.0
 
	/// This value will only be returned if the contract is in a TWS watchlist.
	case notHalted = 0.0
 
	/// Trading halt is imposed for purely regulatory reasons with/without volatility halt.
	case general = 1.0
 
	/// Trading halt is imposed by the exchange to protect against extreme volatility.
	case volatility = 2.0
}