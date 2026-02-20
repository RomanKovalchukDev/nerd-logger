//
//  LogJSONEncoder.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// An encoder that encodes `LogEntity` objects into JSON-formatted strings.
public struct LogJSONEncoder: LogEncoderProtocol {
    
    // MARK: - Properties(private)
    
    private let encoder: JSONEncoder
    private let logOptions: [LogOption]
    
    // MARK: - Life cycle
    
    public init(encoder: JSONEncoder, logOptions: [LogOption]) {
        self.encoder = encoder
        self.logOptions = logOptions
    }
    
    // MARK: - Methods(public)
    
    /// Encodes a `LogEntity` into a JSON string.
    ///
    /// - Parameter entity: The `LogEntity` to encode.
    /// - Returns: A JSON string representation of the log entity.
    /// - Throws: `EncodingError` if the encoding fails.
    public func encode(_ entity: LogEntity) throws -> String {
        let filteredEntity = updateEntityToIncludeOnlyNeededOptions(entity)
        let dto = LogEntityDTO(logEntity: filteredEntity)
        let data = try encoder.encode(dto)
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(
                data,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Unable to convert encoded data to UTF-8 string"
                )
            )
        }
        
        return string
    }
    
    // MARK: - Methods(private)
    
    private func updateEntityToIncludeOnlyNeededOptions(_ entity: LogEntity) -> LogEntity {
        let includeTimestamp = logOptions.contains(.timestamp)
        let includeTag = logOptions.contains(.tag)
        let includeThread = logOptions.contains(.thread)
        let includeFileInfo = logOptions.contains(.fileInfo)
        let includeOtherInfo = logOptions.contains(.otherInfo)
        
        return LogEntity(
            logLevel: entity.logLevel,
            message: entity.message,
            tag: includeTag ? entity.tag : nil,
            date: includeTimestamp ? entity.date : nil,
            functionName: includeFileInfo ? entity.functionName : nil,
            fileName: includeFileInfo ? entity.fileName : nil,
            lineNumber: includeFileInfo ? entity.lineNumber : nil,
            thread: includeThread ? entity.thread : nil,
            extraInfo: includeOtherInfo ? entity.extraInfo : [:]
        )
    }
}
