//
//  LogLevel.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 15.09.2025.
//

/// Severity levels for log records, ordered from least to most severe.
///
/// The raw `Int` values define the natural ordering used by ``LogSeverityFilter`` and the
/// `Comparable` conformance. Higher rawValue means higher severity.
public enum LogLevel: Int, CaseIterable, Sendable, Codable {
    /// Verbose diagnostic information useful only during development.
    case debug

    /// Informational messages describing normal operation.
    case info

    /// Recoverable problems that indicate degraded behavior.
    case warning

    /// Errors that prevented an operation from completing.
    case error

    /// Severe errors that likely require immediate attention.
    case critical

    /// Uppercase textual name of the severity level (for example `"DEBUG"`, `"ERROR"`).
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
    /// Returns `true` when `lhs` is less severe than `rhs`.
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
