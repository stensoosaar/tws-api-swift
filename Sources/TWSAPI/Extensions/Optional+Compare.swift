//
//  IBAPBMarketDataRequest.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//


import Foundation


extension Optional where Wrapped: Comparable {
	
	static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
		guard let leftValue = lhs, let righValue = rhs else {return false}
		return leftValue < righValue
	}
	
	static func > (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
		guard let leftValue = lhs, let righValue = rhs else {return false}
		return leftValue > righValue
	}
	
	static func <= (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
		guard let leftValue = lhs, let righValue = rhs else {return false}
		return leftValue <= righValue
	}
	
	static func >= (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
		guard let leftValue = lhs, let righValue = rhs else {return false}
		return leftValue >= righValue
	}
	
}
