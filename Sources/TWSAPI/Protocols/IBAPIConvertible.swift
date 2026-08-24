//
//  IBAPIConvertible.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//


protocol IBAPIConvertible: Sendable {
	associatedtype ConversionResult
	func convert() throws -> ConversionResult
}


public enum CodingError: Error, Sendable{
	case failedToEncode(_ details: String)
	case failedToDecode(_ details: String)
}
