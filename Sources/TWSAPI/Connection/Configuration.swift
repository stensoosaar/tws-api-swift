//
//  Configuration.swift
//  tws-api-swift
//
//  Created by Sten Soosaar on 16.02.2026.
//


public extension Connection{
	
	struct Configuration: Sendable {
		
		public let host: String
		public let port: Int
		public let capabilities: String?
		public let options: String?
		public let acceptedVersions: ClosedRange<ServerVersion>
		
		public init(host: String, port: Int, capabilities: String? = nil, options: String? = nil) {
			self.host = host
			self.port = port
			self.capabilities = capabilities
			self.options = options
			acceptedVersions = ServerVersion.protobuf ... ServerVersion.config
		}
		
		public enum ConnectionType{
			case gateway
			case workstation
			
			var paperTradingPort: Int{
				switch self {
				case .gateway: return 4002
				case .workstation: return 7497
				}
			}
			
			var livePort: Int{
				switch self {
				case .gateway: return 4001
				case .workstation: return 7496
				}
			}
			
		}
		
		public static func simulated(_ type:ConnectionType)->Connection.Configuration{
			return Connection.Configuration(
				host: "127.0.0.1",
				port: type.paperTradingPort,
				capabilities: nil,
				options: nil
			)
		}
		
		public static func live(_ type:ConnectionType)->Connection.Configuration{
			return Connection.Configuration(
				host: "127.0.0.1",
				port: type.livePort,
				capabilities: nil,
				options: nil
			)
		}
		
	}
	
}
