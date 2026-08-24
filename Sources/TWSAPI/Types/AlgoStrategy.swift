//
//  AlgoStrategy.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 11.06.2026.
//




public enum AlgoStrategy: String, Codable, Sendable {
	case arrivalPrice 				= "ArrivalPx"
	case darkIce 					= "DarkIce"
	case percentageofVolume 		= "PctVol"
	case timeWeightedAveragePrice	= "Twap"
	case volumeWeightedAveragePrice = "Vwap"
}
	
public enum AuctionStrategy: Int32, Codable, Sendable {
	case match 			= 1
	case improvement 	= 2
	case transparent 	= 3
}
	
public enum ClearingIntent: String, Codable, Sendable {
	case ib 					= "IB"
	case away 					= "Away"
	case postTradeAllocation 	= "PTA"
}
	

public enum OpenClose: String, Codable, Sendable {
	/// Open a new position.
	case open 					= "O"
		
	/// Close an existing position.
	case close 					= "C"
}
	
public enum Origin: Int32, Codable, Sendable {
	case customer 				= 0
	case firm 					= 1
	case unknown 				= 2
}
	

	
public enum Rule80AType: String, Codable, Sendable {
		
	/// Individual investor order.
	case individual 			= "I"
	
	/// Agency order.
	case agency 				= "A"
	
	/// Agent other member order.
	case agentOtherMember 		= "W"
	
	/// Individual PTIA (Proprietary Trading Information Aggregator) order.
	case individualPTIA 		= "J"
	
	/// Agency PTIA order.
	case agencyPTIA 			= "U"
	
	/// Agent other member PTIA order.
	case agentOtherMemberPTIA 	= "M"
		
	/// Individual PT (Proprietary Trading) order.
	case individualPT 			= "K"
		
	/// Agency PT order.
	case agencyPT 				= "Y"
		
	/// Agent other member PT order.
	case agentOtherMemberPT 	= "N"
}
	
public enum ShortSaleSlot: Int32, Codable, Sendable{
	case broker 				= 1
	case thirdParty 			= 2
}
	

