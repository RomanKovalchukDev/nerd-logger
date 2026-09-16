//
//  LogOption.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 15.09.2025.
//

import Foundation

/// Selectable fields that encoders may include in the rendered log output.
///
/// Encoders read a `[LogOption]` list and only emit the corresponding parts of a ``LogEntity``,
/// letting callers tune verbosity per destination (compact for console, verbose for files).
public enum LogOption: String, CaseIterable, Sendable {
    /// Logs the timestamp (e.g. "[2019-05-04 13:25:55 GMT+02:00]")
    case timestamp
    
    /// Logs the level/priority (e.g. "[DEBUG]")
    case level
    
    /// Logs the service name (e.g. "[MyService]")
    case tag
    
    /// Logs the file name, function name and line number (e.g. "[MyFile.swift MyClass.myFunction():25]")
    case fileInfo
    
    /// Thread name, main or id of the thread
    case thread
    
    /// Logs any other information (e.g. "[UserID: 12345678]")
    case otherInfo
    
    /// Logs the actual message
    case message
}

/// Preset ``LogOption`` groupings for common formatter configurations.
public extension LogOption {
    /// Default option set: timestamp, level, tag, other info, message.
    static let `default`: [LogOption] = [
        .timestamp,
        .level,
        .tag,
        .otherInfo,
        .message
    ]
    
    /// Compact option set for debug builds: timestamp, level, tag, message.
    static let debug: [LogOption] = [
        .timestamp,
        .level,
        .tag,
        .message
    ]

    /// Option set suitable for console output: timestamp, level, tag, message.
    static let console: [LogOption] = [
        .timestamp,
        .level,
        .tag,
        .message
    ]

    /// Minimal option set for log reports: timestamp, level, message.
    static let logReport: [LogOption] = [
        .timestamp,
        .level,
        .message
    ]

    /// Option set that emits only the message body.
    static let messageOnly: [LogOption] = [
        .message
    ]

    /// All available options in their natural order.
    static let all: [LogOption] = LogOption.allCases
}
