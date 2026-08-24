//
//  Request.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 07.06.2026.
//

import Foundation
import TWSModels
import SwiftProtobuf

public protocol Request: Sendable, Equatable, SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase{
	var type: RequestType {get}
}

public protocol UserRequest: Request{
	var reqID: Int32 {get set}
}

public protocol CancellableRequest: Request{
	var cancel: any Request {get}
}

