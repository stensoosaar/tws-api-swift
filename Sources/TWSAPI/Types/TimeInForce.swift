//
//  TimeInForce.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 06.06.2026.
//


public enum TimeInForce: String, Codable, Sendable {
	   
	   /// Valid for the day only. The order expires at the end of the trading day if not filled.
	   case day	 = "DAY"
	   
	   /**
		Good Until Canceled.
		The order remains active until executed or manually canceled.
		Automatically canceled under these conditions:
		- Stock split, exchange, or distribution.
		- No IB account login for 90 days.
		- End of the calendar quarter following the current quarter.
		Note: Modified orders get a new auto-expire date.
		GTC orders are not adjusted for dividends.
		*/
	   case gtc 	= "GTC"
	   
	   /// Immediate or Cancel. Any portion not immediately filled is canceled.
	   case ioc 	= "IOC"
	   
	   /**
		Good Until Date.
		Remains active until executed or until the close of market on the specified date.
		*/
	   case gtd 	= "GTD"
	   
	   /// Market-on-open (MOO) or limit-on-open (LOO) order.
	   case opg 	= "OPG"
	   
	   /// Fill or Kill. Entire order must be filled immediately or the whole order is canceled.
	   case fok 	= "FOK"
	   
	   /// Day Until Canceled. Similar to DAY but may be used with specific brokers or platforms.
	   case dtc 	= "DTC"
	   
	   /// Undocumented
	   case gtt 	= "GTT"
	   
	   /// Undocumented
	   case auc 	= "AUC"
	   
	   /// Undocumented
	   case gtx 	= "GTX"
	   
	   case Minutes = "Minutes"


   }
