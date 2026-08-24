//
//  Action.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum Action: String, Sendable, Codable {
	case buy = "BUY"
	case sell = "SELL"
	case short = "SSHORT"
}
