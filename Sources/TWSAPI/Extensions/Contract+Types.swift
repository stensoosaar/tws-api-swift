//
//  Contract+Types.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//

import TWSModels

public extension IBPBContract {
	
	var type: SecuritiesType? {
		get {
			SecuritiesType(rawValue: secType)
		}
		set {
			if let value = newValue {
				secType = value.rawValue
			} else {
				clearSecType()
			}
		}
	}
	
	var idType: IDType? {
		get {
			IDType(rawValue: secIDType)
		}
		set {
			if let value = newValue {
				secIDType = value.rawValue
			} else {
				clearSecIDType()
			}
		}
	}
	
	var executionRight: ExecutionRight? {
		get {
			ExecutionRight(rawValue: right)
		}
		set {
			if let value = newValue {
				right = value.rawValue
			} else {
				clearRight()
			}
		}
	}
	
}
