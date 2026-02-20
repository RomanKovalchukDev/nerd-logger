//
//  LogCSVEncoder.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// An encoder that encodes `LogEntity` objects into CSV-formatted strings.
public struct LogCSVEncoder: LogEncoderProtocol {
    
    // MARK: - Properties(private)
    
    private let delimiter: String
    private let dateFormatter: DateFormatter
    private let logOptions: [LogOption]
    
    // MARK: - Life cycle
    
    public init(delimiter: String, dateFormatter: DateFormatter, logOptions: [LogOption]) {
        self.delimiter = delimiter
        self.dateFormatter = dateFormatter
        self.logOptions = logOptions
    }
    
    // MARK: - Methods(public)
    
    /// Encodes a `LogEntity` into a CSV string.
    ///
    /// Encodes fields based on the logOptions order provided during initialization.
    /// - Parameter entity: The `LogEntity` to encode.
    /// - Returns: A CSV string representation of the log entity.
    /// - Throws: An error if encoding fails.
    public func encode(_ entity: LogEntity) throws -> String {
        var components: [String] = []
        
        // Encode fields based on logOptions order
        for option in logOptions {
            switch option {
            case .level:
                let logLevelDTO = LogLevelDTO(logLevel: entity.logLevel)
                components.append(logLevelDTO.rawValue)
                
            case .timestamp:
                if let date = entity.date {
                    components.append(dateFormatter.string(from: date))
                } else {
                    components.append("")
                }
                
            case .tag:
                components.append(entity.tag ?? "")
                
            case .fileInfo:
                components.append(formatFileInfo(entity))
                
            case .otherInfo:
                if !entity.extraInfo.isEmpty {
                    let extraInfoString = entity.extraInfo
                        .map { "\($0.key):\($0.value)" }
                        .joined(separator: ";")
                        
                    components.append(extraInfoString)
                } 
                else {
                    components.append("")
                }
                
            case .thread:
                components.append(entity.thread ?? "")
                
            case .message:
                components.append(entity.message)
            }
        }
                
        return components.map { escapeCSVField($0) }.joined(separator: delimiter)
    }
    
    // MARK: - Methods(private)
    
    private func escapeCSVField(_ field: String) -> String {
        var escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        // Escape newlines, carriage returns, and tabs
        escaped = escaped.replacingOccurrences(of: "\n", with: "\\n")
        escaped = escaped.replacingOccurrences(of: "\r", with: "\\r")
        escaped = escaped.replacingOccurrences(of: "\t", with: "\\t")
        return "\"\(escaped)\""
    }
    
    private func formatFileInfo(_ entity: LogEntity) -> String {
        var parts: [String] = []
        
        if let fileName = entity.fileName {
            parts.append(fileName)
        }
        
        if let functionName = entity.functionName {
            if let lineNumber = entity.lineNumber {
                parts.append("\(functionName):\(lineNumber)")
            } 
            else {
                parts.append(functionName)
            }
        }
        
        return parts.joined(separator: " ")
    }
}
