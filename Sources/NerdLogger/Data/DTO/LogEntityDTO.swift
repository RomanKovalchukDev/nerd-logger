//
//  LogEntityDTO.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

public struct LogEntityDTO: Codable {
    
    // MARK: - Properties(public)
    
    public let logLevel: LogLevelDTO
    public let message: String
    public let tag: String?
    public let date: Date?
    public let functionName: String?
    public let fileName: String?
    public let lineNumber: UInt?
    public var thread: String?
    public let extraInfo: [String: String]?
    
    // MARK: - Life cycle
    
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

public extension LogEntity {
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
