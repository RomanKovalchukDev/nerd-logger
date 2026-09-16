//
//  LogEntity.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// A single log record that flows through the logging pipeline.
///
/// Filters, encoders, and destinations all operate on `LogEntity` values. Optional fields
/// let call sites omit information they do not have (for example, a message forwarded from
/// another process may lack a call site or thread).
public struct LogEntity: Codable, Sendable {
    /// Severity of the record.
    public var logLevel: LogLevel

    /// The human-readable message body.
    public var message: String

    /// Optional label grouping related messages (subsystem, feature, actor).
    public var tag: String?

    /// Timestamp associated with the record, when known.
    public var date: Date?

    /// Name of the function that produced the log, when captured.
    public var functionName: String?

    /// Source file that produced the log, when captured.
    public var fileName: String?

    /// Line number of the call site, when captured.
    public var lineNumber: UInt?

    /// Descriptor of the thread or dispatch queue that produced the log.
    public var thread: String?

    /// Arbitrary key-value metadata attached to the record.
    public var extraInfo: [String: String]

    /// Creates a log entity with the supplied fields.
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
