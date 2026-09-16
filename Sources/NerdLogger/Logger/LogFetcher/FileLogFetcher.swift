//
//  FileLogFetcher.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation

/// A ``LogFetcherProtocol`` implementation that reads and decodes entries from a single log file.
public final class FileLogFetcher: LogFetcherProtocol {

    // MARK: - Properties(public)

    /// Decoder used to parse each line of the log file into a ``LogEntity``.
    public var decoder: any LogDecoderProtocol

    // MARK: - Properties(private)

    private let fileURL: URL

    // MARK: - Life cycle

    /// Creates a fetcher for the given file.
    /// - Parameters:
    ///   - fileURL: URL of the log file to read.
    ///   - decoder: Decoder that parses each stored line back into a ``LogEntity``.
    public init(fileURL: URL, decoder: any LogDecoderProtocol) {
        self.fileURL = fileURL
        self.decoder = decoder
    }

    // MARK: - Methods(public)

    /// Reads the log file, decodes every line, and returns entries matching the optional predicate.
    /// - Parameter filter: Predicate applied to each decoded entity. When `nil`, all entries are returned.
    /// - Returns: The decoded entries that pass the filter, in file order.
    /// - Throws: An error if the file cannot be read.
    public func fetchLogs(with filter: LogFetcherFilter?) throws -> [LogEntity] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let content = try String(contentsOf: fileURL, encoding: .utf8)
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
