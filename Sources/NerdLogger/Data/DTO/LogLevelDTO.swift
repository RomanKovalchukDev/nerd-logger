//
//  LogLevelDTO.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// Data Transfer Object for `LogLevel` used in encoding and decoding operations.
public enum LogLevelDTO: String, Codable {
    /// Serialized form of ``LogLevel/debug``.
    case debug = "DEBUG"
    /// Serialized form of ``LogLevel/info``.
    case info = "INFO"
    /// Serialized form of ``LogLevel/warning``.
    case warning = "WARNING"
    /// Serialized form of ``LogLevel/error``.
    case error = "ERROR"
    /// Serialized form of ``LogLevel/critical``.
    case critical = "CRITICAL"

    // MARK: - Life cycle

    /// Creates the DTO corresponding to the given domain ``LogLevel``.
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

/// Bridges the domain ``LogLevel`` to its serialized ``LogLevelDTO`` form.
public extension LogLevel {
    /// Reconstructs a domain ``LogLevel`` from its ``LogLevelDTO`` counterpart.
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
