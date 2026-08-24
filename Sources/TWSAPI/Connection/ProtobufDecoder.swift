//
//  ProtobufCodec.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.02.2026.
//

import NIOCore
import Foundation
import SwiftProtobuf
import TWSModels


final class ProtobufDecoder: ChannelInboundHandler, Sendable {
	
	typealias InboundIn = ByteBuffer
	typealias InboundOut = Response
	
	
	// MARK: - Inbound (Decoding)

	func channelRead(context: ChannelHandlerContext, data: NIOAny) {
		var buffer = unwrapInboundIn(data)
		
		guard
			let messageId = buffer.readInteger(as: Int32.self),
			let type = ResponseType(rawValue: messageId - 200)
		else {
			//print("⚠️ Failed to read message ID")
			context.fireErrorCaught(ConnectionError.invalidMessageFormat)
			return
		}
		
		guard let data = buffer.readData(length: buffer.readableBytes) else {
			//print("⚠️ Failed to read protobuf payload")
			context.fireErrorCaught(ConnectionError.invalidMessageFormat)
			return
		}
		
		do {
			let response = try decode(type, from: data)
			context.fireChannelRead(wrapInboundOut(response))
		} catch {
			print(error)
			//print(String(data: data, encoding: .utf8),"\n")
		}
		
	}
	
}


extension ProtobufDecoder {
	private func decode(_ response: Response) throws -> Data {
		return Data()
	}
}


extension ProtobufDecoder {
	
	private func decode(_ type: ResponseType, from data: Data) throws -> Response {
		
		switch type {
					
		case .ERR_MSG:
			let payload = try IBPBErrorMessage(serializedBytes: data)
			return .error(requestID: payload.id, code: payload.errorCode, message: payload.errorMsg)
			
		case .NEWS_BULLETINS:
			let payload = try IBPBNewsBulletin(serializedBytes: data)
			return .newsBulletins(payload)
			
		case .NEXT_VALID_ID:
			let payload = try IBPBNextValidId(serializedBytes: data)
			return .nextOrderID(payload.orderID)
		
		case .CURRENT_TIME:
			let payload = try IBPBCurrentTime(serializedBytes: data)
			return .currentTime(payload.currentTime)

		case .CURRENT_TIME_IN_MILLIS:
			let payload = try IBPBCurrentTimeInMillis(serializedBytes: data)
			return.currentTimeInMS(payload.currentTimeInMillis)
			
		// MARK: - account data
			
		case .MANAGED_ACCTS:
			let payload = try IBPBManagedAccounts(serializedBytes: data)
			let accountsList = payload.accountsList.components(separatedBy: ",")
			return .managedAccounts(accountsList)
			
		case .ACCOUNT_UPDATE_MULTI:
			let payload = try IBPBAccountUpdateMulti(serializedBytes: data)
			return .accountUpdate(requestID: payload.reqID, payload: payload)
		
		case .ACCOUNT_UPDATE_MULTI_END:
			let payload = try IBPBAccountUpdateMultiEnd(serializedBytes: data)
			return .accountUpdateEnd(requestID: payload.reqID)

		case .PNL:
			let payload = try IBPBPnL(serializedBytes: data)
			return .accountPNL(requestID: payload.reqID, payload: payload)

		case .POSITION_MULTI:
			let payload = try IBPBPositionMulti(serializedBytes: data)
			return .positionSize(requestID: payload.reqID, payload: payload)
			
		case .POSITION_MULTI_END:
			let payload = try IBPBPositionMultiEnd(serializedBytes: data)
			return .positionSizeEnd(requestID: payload.reqID)
			
		case .PNL_SINGLE:
			let payload = try IBPBPnLSingle(serializedBytes: data)
			return .positionPNL(requestID: payload.reqID, payload: payload)
			
		case .ACCT_UPDATE_TIME:
			let payload = try IBPBAccountUpdateTime(serializedBytes: data)
			return .accountUpdateTime(time: payload.timeStamp)
			
			
		// MARK: - contract
						
		case .WSH_META_DATA:
			let response = try IBPBWshMetaData(serializedBytes: data)
			guard let payload = response.dataJson.data(using: .utf8) else {
				throw CodingError.failedToEncode("IBAPIWshMetaData JSON")
			}
			return .wshMetaData(requestID: response.reqID, json: payload)

		case .WSH_EVENT_DATA:
			let response = try IBPBWshEventData(serializedBytes: data)
			guard let payload = response.dataJson.data(using: .utf8) else {
				throw CodingError.failedToEncode("IBAPIWshEventData JSON")
			}
			return .wshEventData(requestID: response.reqID, json: payload)
			
		case .SYMBOL_SAMPLES:
			let payload = try IBPBSymbolSamples(serializedBytes: data)
			return .matchingSymbols(requestID: payload.reqID, payload: payload.contractDescriptions)

		case .CONTRACT_DATA:
			let payload = try IBPBContractData(serializedBytes: data)
			return .contractDetails(requestID: payload.reqID, contract: payload.contract, details: payload.contractDetails)

		case .BOND_CONTRACT_DATA:
			let payload = try IBPBContractData(serializedBytes: data)
			return .contractDetails(requestID: payload.reqID, contract: payload.contract, details: payload.contractDetails)

		case .CONTRACT_DATA_END:
			let payload = try IBPBContractDataEnd(serializedBytes: data)
			return .contractDetailsEnd(requestID: payload.reqID)

		case .SECURITY_DEFINITION_OPTION_PARAMETER:
			let payload = try IBPBSecDefOptParameter(serializedBytes: data)
			return .optionDetails(requestID: payload.reqID, details: payload)
			
		case .SECURITY_DEFINITION_OPTION_PARAMETER_END:
			let payload = try IBPBSecDefOptParameter(serializedBytes: data)
			return.optionDetailsEnd(requestID: payload.reqID)
			
		case .SCANNER_PARAMETERS:
			let response = try IBPBScannerParameters(serializedBytes: data)
			guard let payload = response.xml.data(using: .utf8) else {
				throw CodingError.failedToEncode("SCANNER_PARAMETERS XML")
			}
			return .scannerParameters(xml: payload)

		case .SCANNER_DATA:
			let response = try IBPBScannerData(serializedBytes: data)
			return .scannerData(requestID: response.reqID, payload: response.scannerDataElement)

		// MARK: - market data
		case .HISTOGRAM_DATA:
			let payload = try IBPBHistogramData(serializedBytes: data)
			return .histogram(requestID: payload.reqID, payload: payload.histogramDataEntries)

		case .HISTORICAL_DATA:
			let payload = try IBPBHistoricalData(serializedBytes: data)
			return .historicBars(requestID: payload.reqID, payload: payload.historicalDataBars)

		case .HISTORICAL_DATA_UPDATE:
			let payload = try IBPBHistoricalDataUpdate(serializedBytes: data)
			return .historicalBarUpdate(requestID: payload.reqID, payload: payload.historicalDataBar)
			
		case .REAL_TIME_BARS:
			let payload = try IBPBRealTimeBarTick(serializedBytes: data)
			return .barUpdate(requestID: payload.reqID, payload: payload)

		case .HISTORICAL_DATA_END:
			let payload = try IBPBHistoricalDataEnd(serializedBytes: data)
			return Response.historicalBarsEnd(requestID: payload.reqID)

		case .HISTORICAL_TICKS:
			let payload = try IBPBHistoricalTicks(serializedBytes: data)
			return .historicalTicks(requestID: payload.reqID, payload: payload.historicalTicks, done: payload.isDone)

		case .HISTORICAL_TICKS_LAST:
			let payload = try IBPBHistoricalTicksLast(serializedBytes: data)
			return .historicalTicksLast(requestID: payload.reqID, payload: payload.historicalTicksLast, done: payload.isDone)

		case .HISTORICAL_TICKS_BID_ASK:
			let payload = try IBPBHistoricalTicksBidAsk(serializedBytes: data)
			return .historicalTicksBidAsk(requestID: payload.reqID, payload: payload.historicalTicksBidAsk, done: payload.isDone)
			
		case .HEAD_TIMESTAMP:
			let payload = try IBPBHeadTimestamp(serializedBytes: data)
			return .headTimestamp(requestID: payload.reqID, date: payload.headTimestamp)
			
			
		// remapped tick events
		case .TICK_PRICE:
			let payload = try IBPBTickPrice(serializedBytes: data)
			return try payload.convert()

		case .TICK_SIZE:
			let payload = try IBPBTickSize(serializedBytes: data)
			return try payload.convert()

		case .TICK_GENERIC:
			let payload = try IBPBTickGeneric(serializedBytes: data)
			return try payload.convert()

		case .TICK_STRING:
			let payload = try IBPBTickString(serializedBytes: data)
			return try payload.convert()
		
		case .MARKET_DEPTH:
			let payload = try IBPBMarketDepth(serializedBytes: data)
			return .marketDepth(requestID: payload.reqID, payload: payload.marketDepthData)

		case .MARKET_DEPTH_L2:
			let payload = try IBPBMarketDepthL2(serializedBytes: data)
			return .marketDepth(requestID: payload.reqID, payload: payload.marketDepthData)

		case .MARKET_RULE:
			let payload = try IBPBMarketRule(serializedBytes: data)
			return .marketRule(ruleID: payload.marketRuleID, payload: payload.priceIncrements)
			
		case .TICK_BY_TICK:
			let payload = try IBPBTickByTickData(serializedBytes: data)
			switch payload.tick{
			case .historicalTickBidAsk(let quote):
				return .tickByTickBidAsk(requestID: payload.reqID, payload: quote)
			case .historicalTickLast(let last):
				return .tickByTickLast(requestID: payload.reqID, payload: last)
			case .historicalTickMidPoint(let mid):
				return .tickByTickMid(requestID: payload.reqID, payload: mid)
			default:
				throw CodingError.failedToDecode("TICK_BY_TICK tick type \(payload.tick.debugDescription)")
			}
			
		case .TICK_SNAPSHOT_END:
			let payload = try IBPBTickSnapshotEnd(serializedBytes: data)
			return .tickSnapshotEnd(requestID: payload.reqID)
			
		case .MARKET_DATA_TYPE:
			let payload = try IBPBMarketDataType(serializedBytes: data)
			return .marketDataType(requestID: payload.reqID, type: payload.marketDataType)
			
		case .TICK_REQ_PARAMS:
			let payload = try IBPBTickReqParams(serializedBytes: data)
			return .tickParameters(requestID: payload.reqID, payload: payload)

		case .REROUTE_MKT_DATA_REQ:
			let payload = try IBPBRerouteMarketDataRequest(serializedBytes: data)
			return .rerouteMarketData(requestID: payload.reqID, conid: payload.conID, exchange: payload.exchange)

		case .REROUTE_MKT_DEPTH_REQ:
			let payload = try IBPBRerouteMarketDepthRequest(serializedBytes: data)
			return .rerouteMarketData(requestID: payload.reqID, conid: payload.conID, exchange: payload.exchange)

			
		// MARK: - orders

		case .OPEN_ORDER:
			let payload = try IBPBOpenOrder(serializedBytes: data)
			return .openOrder(orderID: payload.orderID, contract: payload.contract, order: payload.order, state: payload.orderState)

		case .OPEN_ORDER_END:
			//let payload = try IBAPIOpenOrdersEnd(serializedBytes: data)
			return .openOrderEnd

		case .ORDER_BOUND:
			let payload = try IBPBOrderBound(serializedBytes: data)
			return .orderBound(permID: payload.permID, clientID: payload.clientID, orderID: payload.orderID)

		case .ORDER_STATUS:
			let payload = try IBPBOrderStatus(serializedBytes: data)
			return .executionUpdate(payload)

		case .COMPLETED_ORDER:
			let payload = try IBPBCompletedOrder(serializedBytes: data)
			return .completedOrder(contract: payload.contract, order: payload.order, state: payload.orderState)

		case .COMPLETED_ORDERS_END:
			//let payload = try IBAPICompletedOrdersEnd(serializedBytes: data)
			return .completedOrderEnd

		case .EXECUTION_DATA:
			let payload = try IBPBExecutionDetails(serializedBytes: data)
			return .execution(requestID: payload.reqID, contract: payload.contract, execution: payload.execution)
			
		case .EXECUTION_DATA_END:
			let payload = try IBPBExecutionDetailsEnd(serializedBytes: data)
			return .executionEnd(requestID: payload.reqID)

		case .COMMISSION_AND_FEES_REPORT:
			let payload = try IBPBCommissionAndFeesReport(serializedBytes: data)
			return .commissionReport(payload)
		
		default:
			throw CodingError.failedToDecode("unsupoorted message type \(type)")
		}
	}

	
}


