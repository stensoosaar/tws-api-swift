//
//  TickByTickType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum TickByTickType: String, Sendable, Codable {
	case Last = "Last"
	case AllLast = "AllLast"
	case BidAsk = "BidAsk"
	case MidPoint = "MidPoint"
}
