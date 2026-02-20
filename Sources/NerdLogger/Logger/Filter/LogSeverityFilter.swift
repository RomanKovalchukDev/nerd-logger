//
//  LogSeverityFilter.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

public struct LogSeverityFilter: LogFilterProtocol {
    
    public let id: String
    private let minLogLevel: LogLevel
    
    public init(id: String, minLogLevel: LogLevel) {
        self.id = id
        self.minLogLevel = minLogLevel
    }
    
    public func shouldIgnoreLog(_ entity: LogEntity) -> Bool {
        entity.logLevel < minLogLevel
    }
}
