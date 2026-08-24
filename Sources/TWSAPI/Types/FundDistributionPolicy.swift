//
//  FundDistributionPolicy.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


enum FundDistributionPolicy: String, Sendable, Codable{
	case income = "Y"
	case accumulation = "N"
}

extension FundDistributionPolicy: CustomStringConvertible{
	
	public var description: String{
		switch self {
		case .income: return "Income"
		case .accumulation: return "Accumulation"
		}
	}
}
