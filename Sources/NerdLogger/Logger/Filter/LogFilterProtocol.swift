//
//  LogFilterProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// A predicate that decides whether a ``LogEntity`` should be dropped before it reaches a destination's encoder.
public protocol LogFilterProtocol: TypeNameProtocol {
    /// Unique identifier for this filter instance.
    var id: String { get }

    /// Returns `true` if `entity` should be silently discarded.
    /// - Parameter entity: The record to evaluate.
    func shouldIgnoreLog(_ entity: LogEntity) -> Bool
}
