//
//  IBPBObjects+Request.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 10.06.2026.
//

import TWSModels

//MARK: - Protocol conformance

// account
extension IBPBManagedAccountsRequest: Request{
	public var type: RequestType {.REQ_MANAGED_ACCTS}
}

extension IBPBAccountDataRequest: Request{
	public var type: RequestType {.REQ_ACCT_DATA}
}

extension IBPBAccountSummaryRequest: UserRequest{
	public var type: RequestType {.REQ_ACCOUNT_SUMMARY}
}

extension IBPBAccountUpdatesMultiRequest: UserRequest{
	public var type: RequestType {.REQ_ACCOUNT_UPDATES_MULTI}
}

extension IBPBPnLRequest: UserRequest{
	public var type: RequestType {.REQ_PNL}
}

extension IBPBPnLSingleRequest: UserRequest{
	public var type: RequestType {.REQ_PNL_SINGLE}
}

extension IBPBPositionsMultiRequest: UserRequest{
	public var type: RequestType {.REQ_POSITIONS_MULTI}
}

extension IBPBPositionsRequest: Request{
	public var type: RequestType {.REQ_POSITIONS}
}

// contract
extension IBPBMatchingSymbolsRequest: UserRequest{
	public var type: RequestType {.REQ_MATCHING_SYMBOLS}
}

extension IBPBContractDataRequest: UserRequest{
	public var type: RequestType {.REQ_CONTRACT_DATA}
}

extension IBPBWshEventDataRequest: UserRequest{
	public var type: RequestType {.REQ_WSH_EVENT_DATA}
}

extension IBPBWshMetaDataRequest: UserRequest{
	public var type: RequestType {.REQ_WSH_META_DATA}
}

extension IBPBSecDefOptParamsRequest: UserRequest{
	public var type: RequestType {.REQ_SEC_DEF_OPT_PARAMS}
}

extension IBPBScannerParametersRequest: Request{
	public var type: RequestType {.REQ_SCANNER_PARAMETERS}
}

extension IBPBScannerSubscriptionRequest: UserRequest{
	public var type: RequestType {.REQ_SCANNER_SUBSCRIPTION}
}

// market data
extension IBPBCalculateImpliedVolatilityRequest: UserRequest{
	public var type: RequestType {.REQ_CALC_IMPLIED_VOLAT}
}

extension IBPBCalculateOptionPriceRequest: UserRequest{
	public var type: RequestType {.REQ_CALC_OPTION_PRICE}
}

extension IBPBHeadTimestampRequest: UserRequest{
	public var type: RequestType {.REQ_HEAD_TIMESTAMP}
}

extension IBPBHistogramDataRequest: UserRequest{
	public var type: RequestType {.REQ_HISTOGRAM_DATA}
}

extension IBPBHistoricalDataRequest: UserRequest{
	public var type: RequestType {.REQ_HISTORICAL_DATA}
}

extension IBPBHistoricalNewsRequest: UserRequest{
	public var type: RequestType {.REQ_HISTORICAL_NEWS}
}

extension IBPBHistoricalTicksRequest: UserRequest{
	public var type: RequestType {.REQ_HISTORICAL_TICKS}
}

extension IBPBMarketDataRequest: UserRequest{
	public var type: RequestType {.REQ_MKT_DATA}
}

extension IBPBMarketDataTypeRequest: Request{
	public var type: RequestType {.REQ_MARKET_DATA_TYPE}
}

extension IBPBMarketDepthExchangesRequest: Request{
	public var type: RequestType {.REQ_MKT_DEPTH_EXCHANGES}
}

extension IBPBMarketDepthRequest: UserRequest{
	public var type: RequestType {.REQ_MKT_DEPTH}
}

extension IBPBMarketRuleRequest: Request{
	public var type: RequestType {.REQ_MARKET_RULE}
}

extension IBPBNewsArticleRequest: UserRequest{
	public var type: RequestType {.REQ_NEWS_ARTICLE}
}

extension IBPBNewsBulletinsRequest: Request{
	public var type: RequestType {.REQ_NEWS_BULLETINS}
}

extension IBPBNewsProvidersRequest: Request{
	public var type: RequestType {.REQ_NEWS_PROVIDERS}
}

extension IBPBTickByTickRequest: UserRequest{
	public var type: RequestType {.REQ_TICK_BY_TICK_DATA}
}

extension IBPBRealTimeBarsRequest: UserRequest{
	public var type: RequestType {.REQ_REAL_TIME_BARS}
}

extension IBPBSmartComponentsRequest: UserRequest{
	public var type: RequestType {.REQ_SMART_COMPONENTS}
}


// orders
extension IBPBAllOpenOrdersRequest: Request{
	public var type: RequestType {.REQ_ALL_OPEN_ORDERS}
}

extension IBPBAutoOpenOrdersRequest: Request{
	public var type: RequestType {.REQ_AUTO_OPEN_ORDERS}
}

extension IBPBCompletedOrdersRequest: Request{
	public var type: RequestType {.REQ_COMPLETED_ORDERS}
}

extension IBPBExecutionRequest: UserRequest{
	public var type: RequestType {.REQ_EXECUTIONS}
}

extension IBPBExerciseOptionsRequest: Request{
	public var type: RequestType {.EXERCISE_OPTIONS}
}

extension IBPBOpenOrdersRequest: Request{
	public var type: RequestType {.REQ_OPEN_ORDERS}
}

extension IBPBPlaceOrderRequest: Request{
	public var type: RequestType {.PLACE_ORDER}
}


// system
extension IBPBConfigRequest: UserRequest{
	public var type: RequestType {.REQ_CONFIG}
}
extension IBPBCurrentTimeInMillisRequest: Request{
	public var type: RequestType {.REQ_CURRENT_TIME_IN_MILLIS}
}
extension IBPBCurrentTimeRequest: Request{
	public var type: RequestType {.REQ_CURRENT_TIME}
}
extension IBPBFamilyCodesRequest: Request{
	public var type: RequestType {.REQ_FAMILY_CODES}
}
extension IBPBFARequest: Request{
	public var type: RequestType {.REQ_FA}
}
extension IBPBIdsRequest: Request{
	public var type: RequestType {.REQ_IDS}
}
extension IBPBSetServerLogLevelRequest: Request{
	public var type: RequestType {.SET_SERVER_LOGLEVEL}
}
extension IBPBQueryDisplayGroupsRequest: UserRequest{
	public var type: RequestType {.QUERY_DISPLAY_GROUPS}
}
extension IBPBSoftDollarTiersRequest: UserRequest{
	public var type: RequestType {.REQ_SOFT_DOLLAR_TIERS}
}
extension IBPBStartApiRequest: Request{
	public var type: RequestType {.START_API}
}
extension IBPBSubscribeToGroupEventsRequest: UserRequest{
	public var type: RequestType {.SUBSCRIBE_TO_GROUP_EVENTS}
}

extension IBPBUnsubscribeFromGroupEventsRequest: UserRequest{
	public var type: RequestType {.UNSUBSCRIBE_FROM_GROUP_EVENTS}
}

extension IBPBUpdateConfigRequest: UserRequest{
	public var type: RequestType {.UPDATE_CONFIG}
}

extension IBPBUpdateDisplayGroupRequest: UserRequest{
	public var type: RequestType {.UPDATE_DISPLAY_GROUP}
}

extension IBPBUserInfoRequest: UserRequest{
	public var type: RequestType {.REQ_USER_INFO}
}

extension IBPBVerifyMessageRequest: Request{
	public var type: RequestType {.VERIFY_MESSAGE}
}

extension IBPBVerifyRequest: Request{
	public var type: RequestType {.VERIFY_REQUEST}
}

// cancellations
extension IBPBCancelAccountSummary: UserRequest{
	public var type: RequestType {.CANCEL_ACCOUNT_SUMMARY}
}

extension IBPBCancelAccountUpdatesMulti: UserRequest{
	public var type: RequestType {.CANCEL_ACCOUNT_UPDATES_MULTI}
}

extension IBPBCancelCalculateImpliedVolatility: UserRequest{
	public var type: RequestType {.CANCEL_CALC_IMPLIED_VOLAT}
}

extension IBPBCancelCalculateOptionPrice: UserRequest{
	public var type: RequestType {.CANCEL_CALC_OPTION_PRICE}
}

extension IBPBCancelContractData: UserRequest{
	public var type: RequestType {.CANCEL_CONTRACT_DATA}
}

extension IBPBCancelHeadTimestamp: UserRequest{
	public var type: RequestType {.CANCEL_HEAD_TIMESTAMP}
}

extension IBPBCancelHistogramData: UserRequest{
	public var type: RequestType {.CANCEL_HISTOGRAM_DATA}
}

extension IBPBCancelHistoricalData: UserRequest{
	public var type: RequestType {.CANCEL_HISTORICAL_DATA}
}

extension IBPBCancelHistoricalTicks: UserRequest{
	public var type: RequestType {.CANCEL_HISTORICAL_TICKS}
}

extension IBPBCancelMarketData: UserRequest{
	public var type: RequestType {.CANCEL_MKT_DATA}
}

extension IBPBCancelMarketDepth: UserRequest{
	public var type: RequestType {.CANCEL_MKT_DEPTH}
}

extension IBPBCancelNewsBulletins: Request{
	public var type: RequestType {.CANCEL_NEWS_BULLETINS}
}

extension IBPBCancelOrderRequest: Request{
	public var type: RequestType {.CANCEL_ORDER}
}

extension IBPBCancelPnL: UserRequest{
	public var type: RequestType {.CANCEL_PNL}
}

extension IBPBCancelPnLSingle: UserRequest{
	public var type: RequestType {.CANCEL_PNL_SINGLE}
}

extension IBPBCancelPositions: Request{
	public var type: RequestType {.CANCEL_POSITIONS}
}

extension IBPBCancelPositionsMulti: UserRequest{
	public var type: RequestType {.CANCEL_POSITIONS_MULTI}
}

extension IBPBCancelRealTimeBars: UserRequest{
	public var type: RequestType {.CANCEL_REAL_TIME_BARS}
}

extension IBPBCancelScannerSubscription: UserRequest{
	public var type: RequestType {.CANCEL_SCANNER_SUBSCRIPTION}
}

extension IBPBCancelTickByTick: UserRequest{
	public var type: RequestType {.CANCEL_TICK_BY_TICK_DATA}
}

extension IBPBCancelWshEventData: UserRequest{
	public var type: RequestType {.CANCEL_WSH_EVENT_DATA}
}

extension IBPBCancelWshMetaData: UserRequest{
	public var type: RequestType {.CANCEL_WSH_META_DATA}
}

extension IBPBGlobalCancelRequest: Request{
	public var type: RequestType {.REQ_GLOBAL_CANCEL}
}

extension IBPBOrderCancel: Request{
	public var type: RequestType {.CANCEL_ORDER}
}

