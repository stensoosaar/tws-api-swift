//
//  ShortingAvailability.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//


public enum ShortingAvailability: Sendable{
	/// There are at least 1000 shares available for short selling.
	case shortable
	
	/// This contract will be available for short selling if shares can be located
	case locatable
	
	/// Contract is not available for short selling.
	case notShortable
}