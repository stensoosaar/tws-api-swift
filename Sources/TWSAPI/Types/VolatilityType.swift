//
//  VolatilityType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum VolatilityType: Int32, Codable, Sendable {
	
	/// Daily volatility — typically used for short-term pricing models.
	case daily = 1
	
	/// Annual volatility — used for long-term or standardized volatility inputs.
	case annual = 2
}
