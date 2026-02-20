//
//  LogLevel.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 15.09.2025.
//

public enum LogLevel: Int, CaseIterable, Sendable {
    case debug
    case info
    case warning
    case error
    case critical
    
    public var stringRepresentation: String {
        switch self {
        case .debug:
            return "DEBUG"
            
        case .info:
            return "INFO"
            
        case .warning:
            return "WARNING"
            
        case .error:
            return "ERROR"
            
        case .critical:
            return "CRITICAL"
        }
    }
}

extension LogLevel: Comparable {
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
