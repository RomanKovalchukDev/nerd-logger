//
//  SegmentedLogFetcher.swift
//  CIRALogger
//
//  Created by Roman Kovalchuk on 22.04.2026.
//

import Foundation

/// Reads and merges log entries from multiple segment files managed by a `LogFileManager`.
///
/// Conforms to `LogFetcherProtocol` so it can be swapped in via dependency injection
/// wherever a single-file `FileLogFetcher` was used previously.
public final class SegmentedLogFetcher: LogFetcherProtocol {

    // MARK: - Properties(public)

    /// Decoder used to parse each line of each segment file into a ``LogEntity``.
    public var decoder: any LogDecoderProtocol

    // MARK: - Properties(private)

    private let fileManager: any LogFileManagerProtocol

    // MARK: - Life cycle

    /// Creates a segmented fetcher backed by the given file manager.
    /// - Parameters:
    ///   - fileManager: Manager that enumerates the segment files to read.
    ///   - decoder: Decoder that parses each stored line back into a ``LogEntity``.
    public init(fileManager: any LogFileManagerProtocol, decoder: any LogDecoderProtocol) {
        self.fileManager = fileManager
        self.decoder = decoder
    }

    // MARK: - Methods(public)

    /// Reads all segment files in oldest-first order, decodes their entries, and returns a chronologically sorted result.
    ///
    /// Unreadable or corrupt segment files are silently skipped.
    /// - Parameter filter: Predicate applied to each decoded entity. When `nil`, all entries are returned.
    /// - Returns: Decoded entries that pass the filter, sorted by timestamp ascending.
    /// - Throws: Never throws in practice; segment-level errors are swallowed individually.
    public func fetchLogs(with filter: LogFetcherFilter?) throws -> [LogEntity] {
        let fileURLs = fileManager.sortedLogFileURLs()

        var allEntities: [LogEntity] = []

        for fileURL in fileURLs {
            do {
                let entities = try fetchFromFile(url: fileURL, filter: filter)
                allEntities.append(contentsOf: entities)
            }
            catch {
                // Skip unreadable segment files (partial writes, corrupt data)
                continue
            }
        }

        allEntities.sort { first, second in
            guard let firstDate = first.date else {
                return false
            }
            guard let secondDate = second.date else {
                return false
            }
            return firstDate < secondDate
        }

        return allEntities
    }

    // MARK: - Methods(private)

    private func fetchFromFile(url: URL, filter: LogFetcherFilter?) throws -> [LogEntity] {
        let content = try String(contentsOf: url, encoding: .utf8)
        let lines = decoder.splitContent(content)

        var entities: [LogEntity] = []

        for line in lines {
            do {
                guard let entity = try decoder.decode(line) else {
                    continue
                }

                if let filter {
                    if filter(entity) {
                        entities.append(entity)
                    }
                }
                else {
                    entities.append(entity)
                }
            }
            catch {
                continue
            }
        }

        return entities
    }
}
