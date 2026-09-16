//
//  LogEntityDTO.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// Data transfer object used to serialize a ``LogEntity`` to and from persistent formats.
///
/// Distinct from the domain ``LogEntity`` so encoders can control field naming and
/// optionality without leaking encoding concerns into the domain model.
public struct LogEntityDTO: Codable {
    
    // MARK: - Properties(public)
    
    /// Serialized severity level.
    public let logLevel: LogLevelDTO
    /// Human-readable message body.
    public let message: String
    /// Optional grouping label.
    public let tag: String?
    /// Timestamp associated with the record.
    public let date: Date?
    /// Name of the function that produced the log.
    public let functionName: String?
    /// Source file that produced the log.
    public let fileName: String?
    /// Line number of the call site.
    public let lineNumber: UInt?
    /// Descriptor of the thread or dispatch queue that produced the log.
    public var thread: String?
    /// Arbitrary key-value metadata attached to the record.
    public let extraInfo: [String: String]?
    
    // MARK: - Life cycle
    
    /// Creates a DTO snapshot of the given ``LogEntity``.
    public init(logEntity: LogEntity) {
        self.logLevel = LogLevelDTO(logLevel: logEntity.logLevel)
        self.message = logEntity.message
        self.tag = logEntity.tag
        self.date = logEntity.date
        self.functionName = logEntity.functionName
        self.fileName = logEntity.fileName
        self.lineNumber = logEntity.lineNumber
        self.thread = logEntity.thread
        self.extraInfo = logEntity.extraInfo
    }
}

/// Bridges the domain ``LogEntity`` to its serialized ``LogEntityDTO`` form.
public extension LogEntity {
    /// Reconstructs a ``LogEntity`` from its DTO form, defaulting `extraInfo` to an empty dictionary when absent.
    init(dto: LogEntityDTO) {
        self.logLevel = LogLevel(dto: dto.logLevel)
        self.message = dto.message
        self.tag = dto.tag
        self.date = dto.date
        self.functionName = dto.functionName
        self.fileName = dto.fileName
        self.lineNumber = dto.lineNumber
        self.thread = dto.thread
        self.extraInfo = dto.extraInfo ?? [:]
    }
}
