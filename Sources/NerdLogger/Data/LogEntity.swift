//
//  LogEntity.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

public struct LogEntity {
    public var logLevel: LogLevel
    public var message: String
    public var tag: String?
    public var date: Date?
    public var functionName: String?
    public var fileName: String?
    public var lineNumber: UInt?
    public var thread: String?
    public var extraInfo: [String: String]
    
    public init(
        logLevel: LogLevel,
        message: String,
        tag: String? = nil,
        date: Date? = nil,
        functionName: String? = nil,
        fileName: String? = nil,
        lineNumber: UInt? = nil,
        thread: String? = nil,
        extraInfo: [String: String] = [:]
    ) {
        self.logLevel = logLevel
        self.message = message
        self.tag = tag
        self.date = date
        self.functionName = functionName
        self.fileName = fileName
        self.lineNumber = lineNumber
        self.thread = thread
        self.extraInfo = extraInfo
    }
}
