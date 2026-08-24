//
//  IDType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum IDType: String, Codable, Sendable {
	case cusip = "CUSIP"
	case sedol = "SEDOL"
	case isin = "ISIN"
	case ric = "RIC"
	case figi = "FIGI"
}
