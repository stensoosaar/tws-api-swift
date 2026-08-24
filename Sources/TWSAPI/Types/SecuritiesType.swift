//
//  SecuritiesType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//

public enum SecuritiesType: String, Sendable, Codable {
	case stock = "STK"
	case option = "OPT"
	case future = "FUT"
	case contFuture = "CONTFUT"
	case forex = "CASH"
	case bond = "BOND"
	case cfd = "CFD"
	case fop = "FOP"
	case warrant = "WAR"
	case IOPT = "IOPT"
	case forward = "FWD"
	case bag = "BAG"
	case index = "IND"
	case bill = "BILL"
	case fund = "FUND"
	case fixed = "FIXED"
	case SLB = "SLB"
	case news = "NEWS"
	case commodity = "CMDTY"
	case basket = "BSK"
	case ICU = "ICU"
	case ICS = "ICS"
	case crypto = "CRYPTO"
	case unknown = "None"
}
