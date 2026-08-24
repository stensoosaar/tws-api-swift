//
//  BarEvent.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 12.06.2026.
//


import TWSModels
import Foundation

public protocol BarEvent: Sendable {
	var timestamp: Int64 {get}
	var open: Double {get}
	var high: Double {get}
	var low: Double {get}
	var close: Double {get}
	var volume: String {get}
	var wap: String {get}
	var barCount: Int32 {get}
}



extension IBPBHistoricalDataBar: BarEvent{
	public var timestamp: Int64 {
		if date.count == 8 {
			var components = DateComponents()
			components.year = Int(date.prefix(4))
			components.month = Int(date.dropFirst(4).prefix(2))
			components.day = Int(date.dropFirst(6).prefix(2))
			let timeInterval = Calendar.current
				.date(from: components)!
				.timeIntervalSince1970
			return Int64(timeInterval)
		} else {
			return Int64(date) ?? 0
		}
		
	}
}

extension IBPBRealTimeBarTick: BarEvent {
	public var timestamp: Int64 { 0 }
	public var barCount: Int32{ return count}
}
