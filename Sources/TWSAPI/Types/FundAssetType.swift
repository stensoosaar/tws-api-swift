//
//  FundAssetType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum FundAssetType: String, Sendable, Codable{
	case alternative = "007"
	case guaranteed = "006"
	case sector = "005"
	case equity = "004"
	case multiAsset = "003"
	case fixedIncome = "002"
	case moneyMarket = "001"
	case other = "000"
}

extension FundAssetType: CustomStringConvertible{
	
	public var description: String{
		switch self {
		case .alternative: return "Alternative"
		case .guaranteed: return "Guaranteed"
		case .sector: return "Sector"
		case .equity: return "Equity"
		case .multiAsset: return "Multi-asset"
		case .fixedIncome: return "Fixed Income"
		case .moneyMarket: return "Money Market"
		case .other: return "Others"
		}
	}
}
	
