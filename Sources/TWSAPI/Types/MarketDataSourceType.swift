//
//  EventType.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 08.06.2026.
//


public enum MarketDataSourceType: Int, Codable, Sendable {
	
	/// call & put option volume for current session
	case optionVolume = 100
	
	/// call & put option open interest for current session
	case optionOpenInterest = 101
	
	/// 30-day historical volatility (currently for stocks).
	case optionHistoricalVolatility = 104
	
	/// average volume of the corresponding option contracts
	case averageOptionVolume = 105
	
	/**
	 A prediction of how volatile an underlying will be in the future.
	
	 The IB 30-day volatility is the at-market volatility estimated for a maturity thirty calendar days forward of the
	 current trading day, and is based on option prices from two consecutive expiration months.
	 */
	case optionImpliedVolatility = 106
	
	/// The number of points that the index is over the cash index.
	case indexFuturePremium = 162
	
	/// 13, 26 and 51 week Hi-Lo values. For stocks only.
	case highLowVolumeStats = 165
	
	/// The mark price is the current theoretical calculated value of an instrument.
	case markPrice = 221

	/**
	 Auction price, volume and imbalance
	 
	 * Price - The number of shares that would trade if no new orders were received and the auction were held now.
	 * Volume - The price at which the auction would occur if no new orders were received and the auction were held now.
	 * Imbalance - How many more shares are on one side of the auction than the other.
	 */
	case auction = 225
	
	/// Last trade details (Including both "Last" and "Unreportable Last" trades).
	case realTimeVolumeTimeAndSales = 233

	/// Level of difficulty with which the contract can be sold short & number of shares available to short
	case shortable = 236
	
	/// Contract's news feed.
	case news = 292
	
	/// Trade count for the day.
	case tradeCount = 293
	
	/// Trade count per minute.
	case tradeRate = 294
	
	/// Volume per minute.
	case volumeRate = 295
	
	/// Last Regular Trading Hours traded price.
	case lastRTHTrade = 318
	
	///Last trade details that excludes "Unreportable Trades"
	case realTimeTradeVolume = 375
	
	///30-day real time historical volatility.
	case realTimeHistoricalVolatility = 411

	/// Contract's dividends
	case dividends = 456
	
	/// The bond factor is a number that indicates the ratio of the current bond principal to the original principal
	case bondFactorMultiplier = 460
	
	/// Estimated IPO price range and final price
	case ipoData = 586
	
	/// Total number of outstanding futures contracts
	case futuresOpenInterest = 588
	
	/// 3, 5 and 10 min trading volume
	case shortTermVolume = 595
	
	/// BID and ASK values of etf Net Asset Value. Calculation is based on prices of ETF's underlying securities.
	case navBidAsk = 576
	
	/// LAST price of etf Net Asset Value. Calculation is based on prices of ETF's underlying securities.
	case etfNavLast = 577
	
	/// Today's and previous closing price of ETF contract. Calculation is based on prices of ETF's underlying securities.
	case etfNavClose = 578
	
	/// Hi-Lo values for ETF contract
	case etfNavHighLow = 614
	
	/// ETF Nav Last for Frozen data
	case etfNavFrozenLast = 623
	
	/// Slower mark price update used in system calculations
	case creditmanSlowMarkPrice = 619
	
}
