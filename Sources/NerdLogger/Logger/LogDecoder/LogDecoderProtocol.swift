//
//  LogDecoderProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

/// Parses persisted log strings back into ``LogEntity`` values.
///
/// Paired with ``LogEncoderProtocol`` implementations so a destination and its fetcher speak
/// the same wire format.
public protocol LogDecoderProtocol {
    /// Decodes a single serialized log entry.
    /// - Parameter string: One encoded log record.
    /// - Returns: The parsed ``LogEntity`` or `nil` when the input is empty or unparseable.
    /// - Throws: A `DecodingError` if required fields are missing or malformed.
    func decode(_ string: String) throws -> LogEntity?

    /// Splits file content into individual log entry strings based on the decoder's format.
    /// Default implementation splits by newlines for simple formats like JSON.
    func splitContent(_ content: String) -> [String]
}

/// Default `splitContent` implementation shared by all decoders.
public extension LogDecoderProtocol {
    /// Default implementation: splits `content` by newlines, trims whitespace, and filters empty lines.
    func splitContent(_ content: String) -> [String] {
        content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
