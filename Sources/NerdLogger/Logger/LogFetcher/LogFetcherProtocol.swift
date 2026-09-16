//
//  LogFetcherProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

/// Reads persisted log entries produced by a matching ``LogEncoderProtocol`` and returns them as domain objects.
public protocol LogFetcherProtocol {
    /// Decoder that parses each stored line back into a ``LogEntity``.
    var decoder: any LogDecoderProtocol { get set }

    /// Fetches log entries, optionally filtered by a predicate.
    /// - Parameter filter: Predicate applied to each decoded entity. When `nil`, all entries are returned.
    /// - Returns: The decoded entries that pass the filter.
    /// - Throws: An error if the underlying storage cannot be read.
    func fetchLogs(with filter: LogFetcherFilter?) throws -> [LogEntity]
}
