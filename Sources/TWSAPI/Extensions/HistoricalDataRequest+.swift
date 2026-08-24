//
//  IBAPBMarketDataRequest.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//

import Foundation
import TWSModels

public extension IBPBHistoricalDataRequest {

	/**
	 Convenience property to express the historical data query window as a `DateInterval`.

	 **Setter behaviour:**
	 - If `newValue.end` is in the future, the end date is left empty so TWS streams
	   real-time updates (`keepUpToDate = true`).
	 - Otherwise the end date is encoded using `TimeZone.current`:
	   - UTC → `yyyymmdd-HH:mm:ss`
	   - Other → `yyyymmdd HH:mm:ss XX/XXXX`
	 - `keepUpToDate` is cleared in the historical case.

	 **Getter behaviour:**
	 Reconstructs the interval from `endDateTime` and `duration` using the same
	 fixed multipliers as `twsDescription`, so round-trips are stable.
	 */
	var dateInterval: DateInterval {

		get {
			let end: Date
			if hasEndDateTime && !endDateTime.isEmpty {

				let formatter = DateFormatter()
				formatter.timeZone = TimeZone(identifier: "UTC")
				formatter.dateFormat = "yyyyMMdd-HH:mm:ss"
				if let date = formatter.date(from: endDateTime) {
					end = date
				} else {
					let components = endDateTime.split(separator: " ")
					if components.count >= 2 {
						let zoneIdentifier = components.count == 3 ? String(components[2]) : "UTC"
						formatter.timeZone = TimeZone(identifier: zoneIdentifier) ?? .current
						formatter.dateFormat = "yyyyMMdd HH:mm:ss"
						end = formatter.date(from: "\(components[0]) \(components[1])") ?? Date()
					} else {
						end = Date()
					}
				}
			} else {
				end = Date()
			}

			let seconds: TimeInterval
			if hasDuration && !duration.isEmpty {
				let parts = duration.split(separator: " ")
				if parts.count == 2, let value = Double(parts[0]) {
					switch parts[1] {
					case "S": seconds = value
					case "D": seconds = value * 86_400
					case "M": seconds = value * 2_678_400
					case "Y": seconds = value * 31_536_000
					default:  seconds = 0
					}
				} else {
					seconds = 0
				}
			} else {
				seconds = 0
			}

			return DateInterval(start: end - seconds, end: end)
		}

		set {
			let isOpenEnded = newValue.end > Date.now

			if isOpenEnded {
				clearEndDateTime()
				keepUpToDate = true
			} else {
				let formatter = DateFormatter()
				let zone = TimeZone.current

				if zone.identifier == "UTC" {
					formatter.timeZone = zone
					formatter.dateFormat = "yyyyMMdd-HH:mm:ss"
					endDateTime = formatter.string(from: newValue.end)
				} else {
					formatter.timeZone = zone
					formatter.dateFormat = "yyyyMMdd HH:mm:ss"
					let dateString = formatter.string(from: newValue.end)
					endDateTime = "\(dateString) \(zone.iana ?? "")"
				}

				keepUpToDate = false
			}

			duration = newValue.twsDescription
		}
	}

}
