//
//  LogProtocol+Helpers.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

public extension LogProtocol {
    
    func log(
        _ message: String,
        logLevel: LogLevel
    ) {
        log(message, logLevel: logLevel, date: Date(), tag: nil, fileName: #file, functionName: #function, lineNumber: #line, extraInfo: [:])
    }
    
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
