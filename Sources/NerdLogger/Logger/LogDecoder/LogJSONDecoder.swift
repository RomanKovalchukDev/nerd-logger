//
//  LogJSONDecoder.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// A decoder that decodes JSON-formatted log strings into `LogEntity` objects.
public struct LogJSONDecoder: LogDecoderProtocol {
    
    // MARK: - Properties(private)
    
    private let decoder: JSONDecoder
    
    // MARK: - Life cycle
    
    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    // MARK: - Methods(public)
    
    /// Decodes a JSON string into a `LogEntity`.
    ///
    /// - Parameter string: The JSON string to decode.
    /// - Returns: A `LogEntity` if decoding succeeds, or `nil` if the string is empty or invalid.
    /// - Throws: `DecodingError` if the JSON is malformed or missing required fields.
    public func decode(_ string: String) throws -> LogEntity? {
        guard !string.isEmpty else {
            return nil
        }
        
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        
        let dto = try decoder.decode(LogEntityDTO.self, from: data)
        return LogEntity(dto: dto)
    }
}
