//
//  LogLevelDTO.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// Data Transfer Object for `LogLevel` used in encoding and decoding operations.
public enum LogLevelDTO: String, Codable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
    
    // MARK: - Life cycle
    
    public init(logLevel: LogLevel) {
        switch logLevel {
        case .debug:
            self = .debug
            
        case .info:
            self = .info
            
        case .warning:
            self = .warning
            
        case .error:
            self = .error
            
        case .critical:
            self = .critical
        }
    }
}

public extension LogLevel {
    init(dto: LogLevelDTO) {
        switch dto {
        case .debug:
            self = .debug
            
        case .info:
            self = .info
            
        case .warning:
            self = .warning
            
        case .error:
            self = .error
            
        case .critical:
            self = .critical
        }
    }
}
