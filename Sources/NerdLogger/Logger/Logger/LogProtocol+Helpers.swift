//
//  LogProtocol+Helpers.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// Ergonomic call-site helpers that fill in call-site metadata and per-level shortcuts for ``LogProtocol``.
public extension LogProtocol {

    /// Logs `message` at the given severity, capturing the current call site and timestamp automatically.
    /// - Parameters:
    ///   - message: The message body.
    ///   - logLevel: Severity of the record.
    func log(
        _ message: String,
        logLevel: LogLevel
    ) {
        log(message, logLevel: logLevel, date: Date(), tag: nil, fileName: #file, functionName: #function, lineNumber: #line, extraInfo: [:])
    }
    
    /// Logs `message` at ``LogLevel/debug`` severity.
    func debug(
        _ message: String,
        date: Date = Date(),
        tag: String? = nil,
        fileName: String = #file,
        functionName: String = #function,
        lineNumber: UInt = #line,
        extraInfo: [String: String] = [:]
    ) {
        log(
            message,
            logLevel: .debug,
            date: date,
            tag: tag,
            fileName: fileName,
            functionName: functionName,
            lineNumber: lineNumber,
            extraInfo: extraInfo
        )
    }
    
    /// Logs `message` at ``LogLevel/info`` severity.
    func info(
        _ message: String,
        date: Date = Date(),
        tag: String? = nil,
        fileName: String = #file,
        functionName: String = #function,
        lineNumber: UInt = #line,
        extraInfo: [String: String] = [:]
    ) {
        log(
            message,
            logLevel: .info,
            date: date,
            tag: tag,
            fileName: fileName,
            functionName: functionName,
            lineNumber: lineNumber,
            extraInfo: extraInfo
        )
    }
    
    /// Logs `message` at ``LogLevel/warning`` severity.
    func warning(
        _ message: String,
        date: Date = Date(),
        tag: String? = nil,
        fileName: String = #file,
        functionName: String = #function,
        lineNumber: UInt = #line,
        extraInfo: [String: String] = [:]
    ) {
        log(
            message,
            logLevel: .warning,
            date: date,
            tag: tag,
            fileName: fileName,
            functionName: functionName,
            lineNumber: lineNumber,
            extraInfo: extraInfo
        )
    }
    
    /// Logs `message` at ``LogLevel/error`` severity.
    func error(
        _ message: String,
        date: Date = Date(),
        tag: String? = nil,
        fileName: String = #file,
        functionName: String = #function,
        lineNumber: UInt = #line,
        extraInfo: [String: String] = [:]
    ) {
        log(
            message,
            logLevel: .error,
            date: date,
            tag: tag,
            fileName: fileName,
            functionName: functionName,
            lineNumber: lineNumber,
            extraInfo: extraInfo
        )
    }
    
    /// Logs `message` at ``LogLevel/critical`` severity.
    func critical(
        _ message: String,
        date: Date = Date(),
        tag: String? = nil,
        fileName: String = #file,
        functionName: String = #function,
        lineNumber: UInt = #line,
        extraInfo: [String: String] = [:]
    ) {
        log(
            message,
            logLevel: .critical,
            date: date,
            tag: tag,
            fileName: fileName,
            functionName: functionName,
            lineNumber: lineNumber,
            extraInfo: extraInfo
        )
    }
}
