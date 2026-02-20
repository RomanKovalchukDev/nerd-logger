//
//  LogCSVDecoder.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// A decoder that decodes CSV-formatted log strings into `LogEntity` objects.
public struct LogCSVDecoder: LogDecoderProtocol {
    
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
    
    /// Decodes a CSV string into a `LogEntity`.
    ///
    /// Decodes fields based on the logOptions order provided during initialization.
    /// - Parameter string: The CSV string to decode.
    /// - Returns: A `LogEntity` if decoding succeeds, or `nil` if the string is empty or invalid.
    /// - Throws: An error if the CSV format is invalid or required fields are missing.
    public func decode(_ string: String) throws -> LogEntity? {
        guard !string.isEmpty else {
            return nil
        }
        
        let components = parseCSVLine(string)
        
        var logLevel: LogLevelDTO?
        var timestamp: Date?
        var tag: String?
        var fileInfo: (fileName: String?, functionName: String?, lineNumber: UInt?)?
        var extraInfo: [String: String] = [:]
        var thread: String?
        var message: String?
        
        // Parse fields based on logOptions order
        for (index, option) in logOptions.enumerated() {
            guard index < components.count else {
                break
            }
            
            switch option {
            case .level:
                let logLevelString = components[index]
                logLevel = LogLevelDTO(rawValue: logLevelString)
                
            case .timestamp:
                if let dateString = parseOptionalString(components[index]) {
                    timestamp = dateFormatter.date(from: dateString)
                }
                
            case .tag:
                tag = parseOptionalString(components[index])
                
            case .fileInfo:
                fileInfo = parseFileInfo(components[index])
                
            case .thread:
                thread = parseOptionalString(components[index])
                
            case .otherInfo:
                if let extraInfoString = parseOptionalString(components[index]) {
                    extraInfo = parseExtraInfo(extraInfoString)
                }
                
            case .message:
                message = parseOptionalString(components[index])
            }
        }
        
        guard let logLevelDTO = logLevel else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Log level is required but was not found"
                )
            )
        }
        
        guard let message else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Message is required but was not found"
                )
            )
        }
        
        return LogEntity(
            logLevel: LogLevel(dto: logLevelDTO),
            message: message,
            tag: tag,
            date: timestamp,
            functionName: fileInfo?.functionName,
            fileName: fileInfo?.fileName,
            lineNumber: fileInfo?.lineNumber,
            thread: thread,
            extraInfo: extraInfo
        )
    }
    
    /// Splits CSV file content into individual log entry lines, handling quoted fields properly
    public func splitContent(_ content: String) -> [String] {
        var lines: [String] = []
        var currentLine = ""
        var insideQuotes = false
        var index = content.startIndex
        
        while index < content.endIndex {
            let char = content[index]
            
            if char == "\"" {
                currentLine.append(char)
                // Check for escaped quote
                if insideQuotes && content.index(after: index) < content.endIndex && content[content.index(after: index)] == "\"" {
                    index = content.index(after: index)
                    currentLine.append("\"")
                } else {
                    insideQuotes.toggle()
                }
            } else if char == "\n" && !insideQuotes {
                // Only treat as line break if not inside quotes
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                    currentLine = ""
                }
            } else if char == "\r" && !insideQuotes {
                // Handle carriage return
                if content.index(after: index) < content.endIndex && content[content.index(after: index)] == "\n" {
                    // Skip \r in \r\n
                    index = content.index(after: index)
                }
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                    currentLine = ""
                }
            } else {
                currentLine.append(char)
            }
            
            index = content.index(after: index)
        }
        
        // Add the last line if not empty
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    
    // MARK: - Methods(private)
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var insideQuotes = false
        var index = line.startIndex
        
        while index < line.endIndex {
            let char = line[index]
            
            if char == "\"" {
                if insideQuotes && line.index(after: index) < line.endIndex && line[line.index(after: index)] == "\"" {
                    currentField.append("\"")
                    index = line.index(after: index)
                } else {
                    insideQuotes.toggle()
                }
            } else if char == Character(delimiter) && !insideQuotes {
                result.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
            
            index = line.index(after: index)
        }
        
        result.append(currentField)
        return result
    }
    
    private func parseOptionalString(_ value: String) -> String? {
        var trimmed = value.trimmingCharacters(in: .whitespaces)
        // Unescape newlines, carriage returns, and tabs
        trimmed = trimmed.replacingOccurrences(of: "\\n", with: "\n")
        trimmed = trimmed.replacingOccurrences(of: "\\r", with: "\r")
        trimmed = trimmed.replacingOccurrences(of: "\\t", with: "\t")
        return trimmed.isEmpty ? nil : trimmed
    }
    
    private func parseExtraInfo(_ string: String) -> [String: String] {
        var result: [String: String] = [:]
        
        let pairs = string.components(separatedBy: ";")
        for pair in pairs {
            let components = pair.components(separatedBy: ":")
            if components.count == 2 {
                let key = components[0].trimmingCharacters(in: .whitespaces)
                let value = components[1].trimmingCharacters(in: .whitespaces)
                result[key] = value
            }
        }
        
        return result
    }
    
    private func parseFileInfo(_ string: String) -> (fileName: String?, functionName: String?, lineNumber: UInt?)? {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            return nil
        }
        
        // Expected format: "FileName.swift FunctionName():123"
        let components = trimmed.components(separatedBy: " ")
        guard components.count >= 2 else {
            return (fileName: nil, functionName: nil, lineNumber: nil)
        }
        
        let fileName = components[0]
        let functionAndLine = components[1]
        
        // Split function name and line number
        if let colonIndex = functionAndLine.lastIndex(of: ":") {
            let functionName = String(functionAndLine[..<colonIndex])
            let lineNumberString = String(functionAndLine[functionAndLine.index(after: colonIndex)...])
            let lineNumber = UInt(lineNumberString)
            
            return (fileName: fileName, functionName: functionName, lineNumber: lineNumber)
        } else {
            return (fileName: fileName, functionName: functionAndLine, lineNumber: nil)
        }
    }
}
