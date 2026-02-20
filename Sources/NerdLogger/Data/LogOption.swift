//
//  LogOption.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 15.09.2025.
//

import Foundation

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

public extension LogOption {
    static let `default`: [LogOption] = [
        .timestamp,
        .level,
        .tag,
        .otherInfo,
        .message
    ]
    
    /// Debug option set
    static let debug: [LogOption] = [
        .timestamp,
        .level,
        .tag,
        .message
    ]
    
    /// Console option set
    static let console: [LogOption] = [
        .timestamp,
        .level,
        .tag,
        .message
    ]
    
    /// Report option set
    static let logReport: [LogOption] = [
        .timestamp,
        .level,
        .message
    ]
    
    /// Will only log the message itself
    static let messageOnly: [LogOption] = [
        .message
    ]
    
    /// All possible options in default order
    static let all: [LogOption] = LogOption.allCases
}
