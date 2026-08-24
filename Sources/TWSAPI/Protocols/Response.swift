//
//  Response.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 07.06.2026.
//

import Foundation
import TWSModels


public enum Response: Sendable {
	
	//account & positions
	case managedAccounts(_ identifiers: [String])
	case accountUpdate(requestID: Int32, payload: IBPBAccountUpdateMulti)
	case accountUpdateEnd(requestID: Int32)
	case accountPNL(requestID: Int32, payload: IBPBPnL)
	case positionSize(requestID: Int32, payload: IBPBPositionMulti)
	case positionSizeEnd(requestID: Int32)
	case positionPNL(requestID: Int32, payload: IBPBPnLSingle)
	case accountUpdateTime(time: String)
	
	//contract
	case matchingSymbols(requestID: Int32, payload: [IBPBContractDescription])
	case contractDetails(requestID: Int32, contract: IBPBContract, details: IBPBContractDetails)
	case contractDetailsEnd(requestID: Int32)
	case optionDetails(requestID: Int32, details: IBPBSecDefOptParameter)
	case optionDetailsEnd(requestID: Int32)
	case scannerParameters(xml: Data)
	case scannerData(requestID: Int32, payload: [IBPBScannerDataElement])
	
	//market data
	case histogram(requestID:Int32, payload: [IBPBHistogramDataEntry])
	case historicBars(requestID:Int32, payload:[IBPBHistoricalDataBar])
	case historicalBarUpdate(requestID: Int32, payload: IBPBHistoricalDataBar)
	case historicalBarsEnd(requestID:Int32)
	case barUpdate(requestID: Int32, payload: IBPBRealTimeBarTick)
	case headTimestamp(requestID: Int32, date: String)
	case marketData(requestID: Int32, payload: TickEvent)
	case rerouteMarketData(requestID: Int32, conid: Int32, exchange: String)

	case marketDepth(requestID: Int32, payload: IBPBMarketDepthData)
	case marketDepthExchanges([IBPBDepthMarketDataDescription])
	case rerouteMarketDepth(requestID: Int32, conid: Int32, exchange: String)

	case marketRule(ruleID:Int32, payload: [IBPBPriceIncrement])
	case tickByTickMid(requestID: Int32, payload: IBPBHistoricalTick)
	case tickByTickBidAsk(requestID: Int32, payload: IBPBHistoricalTickBidAsk)
	case tickByTickLast(requestID: Int32, payload: IBPBHistoricalTickLast)
	case historicalTicks(requestID: Int32, payload: [IBPBHistoricalTick], done:Bool)
	case historicalTicksBidAsk(requestID: Int32, payload: [IBPBHistoricalTickBidAsk], done:Bool)
	case historicalTicksLast(requestID: Int32, payload: [IBPBHistoricalTickLast], done:Bool)
	case marketDataType(requestID:Int32, type: Int32)
	case tickParameters(requestID: Int32, payload: IBPBTickReqParams)
	case tickSnapshotEnd(requestID: Int32)
	
	//orders
	case openOrder(orderID:Int32, contract: IBPBContract, order: IBPBOrder, state: IBPBOrderState)
	case openOrderEnd
	case execution(requestID: Int32, contract: IBPBContract, execution: IBPBExecution)
	case executionUpdate(IBPBOrderStatus)
	case executionEnd(requestID: Int32)
	case completedOrder(contract: IBPBContract, order: IBPBOrder, state: IBPBOrderState)
	case completedOrderEnd
	case orderBound(permID: Int64, clientID: Int32, orderID: Int32)
	case commissionReport(IBPBCommissionAndFeesReport)
	
	//fundamentals
	case wshMetaData(requestID: Int32, json: Data)
	case wshEventData(requestID: Int32, json: Data)
	
	//system
	case nextOrderID(Int32)
	case currentTime(Int64)
	case currentTimeInMS(Int64)
	case newsBulletins(IBPBNewsBulletin)
	case error(requestID: Int32, code: Int32, message: String)

}
