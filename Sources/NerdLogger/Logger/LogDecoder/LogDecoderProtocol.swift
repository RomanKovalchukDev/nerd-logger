//
//  LogDecoderProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

public protocol LogDecoderProtocol {
    func decode(_ string: String) throws -> LogEntity?
    
    /// Splits file content into individual log entry strings based on the decoder's format.
    /// Default implementation splits by newlines for simple formats like JSON.
    func splitContent(_ content: String) -> [String]
}

public extension LogDecoderProtocol {
    /// Default implementation: split by newlines and filter empty lines
    func splitContent(_ content: String) -> [String] {
        content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
