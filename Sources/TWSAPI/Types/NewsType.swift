//
//  NewsType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//

public enum NewsType: String, Sendable, Codable {
	case unknown = "UNKNOWN"
	case bbs = "BBS"
	case liveExchange = "LIVE_EXCH"
	case deadExchange = "DEAD_EXCH"
	case html = "HTML"
	case popupText = "POPUP_TEXT"
	case popupHTML = "POPUP_HTML"
}
