//
//  LogSimpleEncoder.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation

/// An encoder that formats `LogEntity` objects as simple single-line strings.
/// Format: [timestamp] [LEVEL] [tag] [info] message
public final class LogSimpleEncoder: LogEncoderProtocol {
    
    // MARK: - Properties(private)
    
    private let dateFormatter: DateFormatter
    private let logOptions: [LogOption]
    private let shouldEscapeMessage: Bool
    
    // MARK: - Life cycle
    
    public init(dateFormatter: DateFormatter, logOptions: [LogOption], shouldEscapeMessage: Bool = true) {
        self.dateFormatter = dateFormatter
        self.logOptions = logOptions
        self.shouldEscapeMessage = shouldEscapeMessage
    }
    
    // MARK: - Methods(public)
    
    public func encode(_ entity: LogEntity) throws -> String {
        var components: [String] = []
        
        for option in logOptions {
            switch option {
            case .timestamp:
                if let date = entity.date {
                    let timestamp = dateFormatter.string(from: date)
                    components.append("[\(sanitize(timestamp))]")
                }

            case .level:
                let levelString = LogLevelDTO(logLevel: entity.logLevel).rawValue
                components.append("[\(levelString)]")

            case .tag:
                if let tag = entity.tag {
                    components.append("[\(sanitize(tag))]")
                }

            case .fileInfo:
                if let fileInfo = formatFileInfo(entity) {
                    components.append("[\(sanitize(fileInfo))]")
                }

            case .thread:
                if let thread = entity.thread {
                    components.append("[\(sanitize(thread))]")
                }

            case .otherInfo:
                if !entity.extraInfo.isEmpty {
                    let info = formatExtraInfo(entity.extraInfo)
                    components.append("[\(sanitize(info))]")
                }

            case .message:
                components.append(sanitize(entity.message))
            }
        }
        
        return components.joined(separator: " ")
    }
    
    // MARK: - Methods(private)
    
    private func sanitize(_ string: String) -> String {
        if shouldEscapeMessage {
            return string
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")
                .replacingOccurrences(of: "\t", with: "\\t")
        }
        else {
            return string
        }
    }
    
    private func formatFileInfo(_ entity: LogEntity) -> String? {
        var parts: [String] = []
        
        if let fileName = entity.fileName {
            parts.append(fileName)
        }
        
        if let functionName = entity.functionName {
            parts.append("\(functionName)()")
        }
        
        if let lineNumber = entity.lineNumber {
            parts.append(":\(lineNumber)")
        }
        
        guard !parts.isEmpty else {
            return nil
        }
        
        return parts.joined(separator: " ")
    }
    
    private func formatExtraInfo(_ extraInfo: [String: String]) -> String {
        extraInfo
            .sorted { $0.key < $1.key }
            .map { "\(sanitize($0.key)):\(sanitize($0.value))" }
            .joined(separator: ";")
    }
}
