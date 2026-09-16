//
//  LogClosureFilter.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// A ``LogFilterProtocol`` implementation that delegates the ignore decision to a caller-supplied closure.
public struct LogClosureFilter: LogFilterProtocol {

    /// Unique identifier for this filter instance.
    public let id: String
    private let onFilter: (LogEntity) -> Bool

    /// Creates a closure-based filter.
    /// - Parameters:
    ///   - id: Unique identifier for this filter.
    ///   - onFilter: Closure that returns `true` when the entity should be discarded.
    public init(id: String, onFilter: @escaping (LogEntity) -> Bool) {
        self.id = id
        self.onFilter = onFilter
    }

    /// Returns the result of invoking the stored closure with `entity`.
    /// - Parameter entity: The record to evaluate.
    public func shouldIgnoreLog(_ entity: LogEntity) -> Bool {
        onFilter(entity)
    }
}
