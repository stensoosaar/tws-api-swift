//
//  BarSize.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum BarSize: String, Sendable, Codable {
	case sec1 = "1 secs"
	case sec5 = "5 secs"
	case sec10 = "10 secs"
	case sec15 = "15 secs"
	case sec30 = "30 secs"
	case min1 = "1 min"
	case min2 = "2 min"
	case min3 = "3 min"
	case min4 = "4 min"
	case min5 = "5 min"
	case min10 = "10 min"
	case min15 = "15 min"
	case min20 = "20 min"
	case min30 = "30 min"
	case hour1 = "1 hour"
	case hours2 = "2 hours"
	case hours4 = "4 hours"
	case day = "1 day"
	case week = "1 week"
	case month = "1 month"
}
