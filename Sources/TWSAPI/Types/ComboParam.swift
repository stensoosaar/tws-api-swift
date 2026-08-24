//
//  ComboParam.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum ComboParam: String, Sendable, Codable {
	case NonGuaranteed = "NonGuaranteed"
	case PriceCondConid = "PriceCondConid"
	case CondPriceMax = "CondPriceMax"
	case CondPriceMin = "CondPriceMin"
	case ChangeToMktTime1 = "ChangeToMktTime1"
	case ChangeToMktTime2 = "ChangeToMktTime2"
	case DiscretionaryPct = "DiscretionaryPct"
	case DontLeginNext = "DontLeginNext"
	case LeginPrio = "LeginPrio"
	case MaxSegSize = "MaxSegSize"
}
