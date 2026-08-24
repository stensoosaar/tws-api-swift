//
//  OcaType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum OCAType: Int32, Codable, Sendable {
	
	/// Cancel all remaining orders in the group when one order (or part of it) is executed. (With block)
	case cancelAll 				= 1
	
	case cancelWithBlocking 	= 2

	/// Reduce the size of remaining orders proportionally. Only one order is routed at a time. (With block)
	case reduceWithBlock 		= 3

	/// Reduce the size of remaining orders proportionally. All orders may be active simultaneously. (No block)
	case reduceWithoutBlock 	= 4
}
