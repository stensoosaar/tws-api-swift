//
//  AlgoParam.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum AlgoParam: String, Sendable, Codable {
	case startTime = "startTime"
	case endTime = "endTime"
	case allowPastEndTime = "allowPastEndTime"
	case maxPctVol = "maxPctVol"
	case pctVol = "pctVol"
	case strategyType = "strategyType"
	case noTakeLiq = "noTakeLiq"
	case riskAversion = "riskAversion"
	case forceCompletion = "forceCompletion"
	case displaySize = "displaySize"
	case getDone = "getDone"
	case noTradeAhead = "noTradeAhead"
	case useOddLots = "useOddLots"
	case componentSize = "componentSize"
	case timeBetweenOrders = "timeBetweenOrders"
	case randomizeTime20 = "randomizeTime20"
	case randomizeSize55 = "randomizeSize55"
	case giveUp = "giveUp"
	case catchUp = "catchUp"
	case waitForFill = "waitForFill"
	case activeTimeStart = "activeTimeStart"
	case activeTimeEnd = "activeTimeEnd"
	case optoutClosingAuction = "optoutClosingAuction"
	case speedUp = "speedUp"
	case optoutOpeningAuction = "optoutOpeningAuction"
	case minPctVol4Px = "minPctVol4Px"
	case maxPctVol4Px = "maxPctVol4Px"
	case deltaPctVol = "deltaPctVol"
	case startPctVol = "startPctVol"
	case endPctVol = "endPctVol"
	case adaptivePriority = "adaptivePriority"
	case routeOrderType = "routeOrderType"
	case activeTimeTz = "activeTimeTz"
	case routeOffset = "routeOffset"
	case minPrice = "minPrice"
	case maxPrice = "maxPrice"
	case takeBlockMinSize = "takeBlockMinSize"
	case takeBlockLmtPrice = "takeBlockLmtPrice"
}
