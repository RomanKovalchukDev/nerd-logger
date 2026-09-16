//
//  LogSeverityFilter.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// A ``LogFilterProtocol`` implementation that drops records below a minimum ``LogLevel``.
public struct LogSeverityFilter: LogFilterProtocol {

    /// Unique identifier for this filter instance.
    public let id: String
    private let minLogLevel: LogLevel

    /// Creates a severity filter.
    /// - Parameters:
    ///   - id: Unique identifier for this filter.
    ///   - minLogLevel: Records with a level lower than this value are discarded.
    public init(id: String, minLogLevel: LogLevel) {
        self.id = id
        self.minLogLevel = minLogLevel
    }

    /// Returns `true` when `entity.logLevel` is below the configured minimum.
    /// - Parameter entity: The record to evaluate.
    public func shouldIgnoreLog(_ entity: LogEntity) -> Bool {
        entity.logLevel < minLogLevel
    }
}
