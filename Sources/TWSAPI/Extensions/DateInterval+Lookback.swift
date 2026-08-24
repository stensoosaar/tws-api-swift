//
//  DateInterval+TWSDuration.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//

import Foundation

extension DateInterval {
		
	/**
		Creates back looking dateinterval
		- parameter value: The number of time units to look back.
		- parameter unit: The calendar component representing the unit of time (e.g. `.day`, `.month`, `.year`).
		- parameter endDate: The end date of the interval. Defaults to the current datetime.
		
		Example, returning the last 7 days ending now
	 
		```swift
		let lastWeek = DateInterval.lookback(7, unit: .day)
		```
	*/
	public static func lookback(_ value: Int, unit: Calendar.Component, until endDate: Date = Date()) -> DateInterval {
		let adjustedEnd = endDate.timeIntervalSince1970 > Date().timeIntervalSince1970 ? Date() : endDate
		let startDate = Calendar.current.date(byAdding: unit, value: -1 * abs(value), to: adjustedEnd)!
		return DateInterval(start: startDate, end: endDate)
	}
	
	var twsDescription: String {
		
		let adjustedEnd = end.timeIntervalSince1970 > Date().timeIntervalSince1970 ? Date() : end
		let adjustedDuration = adjustedEnd.timeIntervalSince1970 - start.timeIntervalSince1970
							
		switch adjustedDuration {
			
		case 0..<86400:
			return String(format: "%d S", Int(adjustedDuration))
		case 86400..<2678400:
			return String(format: "%d D", Int(adjustedDuration/86400))
		case 2678400..<31536000:
			return String(format: "%d M", Int(adjustedDuration/2678400))
		default:
			return String(format: "%d Y", Int(adjustedDuration/31536000))
		}
	
	}
	
	var twsDescriptionLong: String {
		
		let adjustedEnd = end.timeIntervalSince1970 > Date().timeIntervalSince1970 ? Date() : end
		let adjustedDuration = adjustedEnd.timeIntervalSince1970 - start.timeIntervalSince1970
							
		switch adjustedDuration {
			
		case 0..<86400:
			return String(format: "%d seconds", Int(adjustedDuration))
		case 86400..<2678400:
			return String(format: "%d days", Int(adjustedDuration/86400))
		case 2678400..<31536000:
			return String(format: "%d months", Int(adjustedDuration/2678400))
		default:
			return String(format: "%d year", Int(adjustedDuration/31536000))
		}
	
	}
		
}
