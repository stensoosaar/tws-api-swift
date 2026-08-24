//
//  OrderStatus.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 12.06.2026.
//


public enum OrderStatus: String, Sendable, Codable {
	
	case apiPending = "ApiPending"
			
	case apiCancelled = "ApiCancelled"
	
	/**
	 indicates that a simulated order type has been accepted by the IB system and that this order has yet to be elected. The order is held in the IB system until the election criteria are met. At that time the order is transmitted to the order destination as specified.
	 */
	case preSubmitted = "PreSubmitted"
	
	/**
	 indicates that you have sent a request to cancel the order but have not yet received cancel confirmation
	 from the order destination. At this point, your order is not confirmed canceled.
	 It is not guaranteed that the cancellation will be successful.
	 */
	case pendingCancel = "PendingCancel"
	
	///indicates that the balance of your order has been confirmed canceled by the IB system. This could occur unexpectedly when IB or the destination has rejected your order.
	case cancelled = "Cancelled"
	
	///indicates that your order has been accepted by the system.
	case submitted = "Submitted"
	
	///indicates that the order has been completely filled. Market orders executions will not always trigger a Filled status.
	case filled = "Filled"
	
	///indicates that the order was received by the system but is no longer active because it was rejected or canceled.
	case inactive = "Inactive"
	
	///indicates that you have transmitted the order, but have not yet received confirmation that it has been accepted by the order destination.
	case pendingSubmit = "PendingSubmit"
	
}