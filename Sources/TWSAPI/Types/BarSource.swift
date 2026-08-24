//
//  BarSource.swift
//  IBKit
//
//  Created by Sten Soosaar on 08.06.2026.
//


/**
	Defines event type we observe when building the bars
	- Note: Availability of each bar source varies by product type (e.g., Stocks, Options, Futures, Crypto).
 */
public enum BarSource: String, Sendable, Codable {
	/// Trades: Last trade price. 
	/// - Available for: all except commodities, forex, funds, cfd
	/// - Adjusted for splits; not adjusted for dividends.
	case trades = "TRADES"
	
	/// Midpoint: Midpoint between bid and ask.
	/// - Available for: all except indicies
	case midPoint = "MIDPOINT"
	
	/// Bid: Best bid price.
	/// - Available for: all except indicies
	case bid  = "BID"
	
	/// Ask: Best ask price.
	/// - Available for: all except indicies
	case ask = "ASK"
	
	/// Bid/Ask: Both bid and ask, used for constructing bid/ask bars.
	/// - Available for: all except indicies
	case bidAsk = "BID_ASK"
	
	/// Adjusted Last: Last trade price adjusted for splits and dividends.
	/// - Available for: Stocks
	case adjustestLast = "ADJUSTED_LAST"
	
	/// Historical Volatility: Calculated historical volatility value per bar.
	/// - Available for: Stocks, ETF's, Indices
	case historicalVolatility = "HISTORICAL_VOLATILITY"
	
	/// Option Implied Volatility: Calculated implied volatility from option prices.
	/// - Available for: Stocks, ETF's, Indices
	case impliedVolatility = "OPTION_IMPLIED_VOLATILITY"
	
	/// Fee Rate: Applicable fee rate for the product.
	/// - Available for: Crypto, some Futures
	case feeRate = "FEE_RATE"
	
	/// Yield Bid: Bid yield value.
	/// - Available for: Bonds
	case bidYield = "YIELD_BID"
	
	/// Yield Ask: Ask yield value.
	/// - Available for: Bonds
	case askYield = "YIELD_ASK"
	
	/// Yield Bid/Ask: Both bid and ask yields.
	/// - Available for: Bonds
	case bidAskYield = "YIELD_BID_ASK"
	
	/// Last Yield: Last transacted yield.
	/// - Available for: Bonds
	case lastYield = "YIELD_LAST"
	
	/// Schedule: Historical trading schedule; provides trading hours for the instrument. No OHLCV data.
	/// - Available for: all except options, FOP's,
	case schedule = "SCHEDULE"
	
	/// Aggregated Trades: Aggregated trade data from crypto exchanges.
	/// - Available for: Crypto
	case aggregatedTrades = "AGGTRADES"
	
}