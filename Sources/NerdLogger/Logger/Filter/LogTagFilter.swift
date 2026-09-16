//
//  LogTagFilter.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// A ``LogFilterProtocol`` implementation that passes only records whose tag appears in an allowlist.
///
/// Records with a `nil` tag are always discarded.
public struct LogTagFilter: LogFilterProtocol {

    /// Unique identifier for this filter instance.
    public let id: String
    /// The set of tag strings that are allowed through. Records with tags outside this list are dropped.
    public let tags: [String]

    /// Creates a tag allowlist filter.
    /// - Parameters:
    ///   - id: Unique identifier for this filter.
    ///   - tags: Tag strings to allow. Records whose tag is not in this list are discarded.
    public init(id: String, tags: [String]) {
        self.id = id
        self.tags = tags
    }

    /// Returns `true` when `entity.tag` is `nil` or not present in the allowlist.
    /// - Parameter entity: The record to evaluate.
    public func shouldIgnoreLog(_ entity: LogEntity) -> Bool {
        guard let entityTag = entity.tag else {
            return true
        }

        return !tags.contains(entityTag)
    }
}
