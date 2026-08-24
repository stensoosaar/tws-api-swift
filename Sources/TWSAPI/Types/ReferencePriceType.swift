//
//  ReferencePriceType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum ReferencePriceType: Int32, Codable, Sendable {
	
	/// Uses the average of the National Best Bid and Offer (NBBO) as the reference price.
	case averageNBBO 			= 1
	
	/// Uses either the National Best Bid (NBB) or National Best Offer (NBO) depending on the order action and option right.
	case bidOrAsk 				= 2
}
