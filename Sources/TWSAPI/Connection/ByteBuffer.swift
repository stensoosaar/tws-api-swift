//
//  ByteBuffer+Data.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 16.02.2026.
//


import Foundation
import NIOCore


extension ByteBuffer {
	
	mutating func readData(length: Int) -> Data? {
		guard let bytes = readBytes(length: length) else {
			return nil
		}
		return Data(bytes)
	}
	
	@discardableResult
	mutating func writeData(_ data: Data) -> Int {
		return data.withUnsafeBytes { pointer in
			writeBytes(pointer)
			
		}
	}
	
}
