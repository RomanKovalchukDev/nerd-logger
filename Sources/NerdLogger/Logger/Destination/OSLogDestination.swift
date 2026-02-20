//
//  OSLogDestination.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation
import os.log

public final class OSLogDestination: LogDestinationProtocol, TypeNameProtocol {
    
    // MARK: - Properties(public)
    
    public let id: String
    public var filters: [any LogFilterProtocol]
    public var encoder: any LogEncoderProtocol
    public var metadataProvider: (any LogMetadataProvider)?
    
    // MARK: - Properties(private)
    
    private let logger: Logger
    private let executionMethod: ExecutionMethod
    private let onInternalLog: InternalLog?
    
    // MARK: - Life cycle
    
    public init(
        id: String,
        logger: Logger,
        executionMethod: ExecutionMethod,
        filters: [any LogFilterProtocol],
        encoder: any LogEncoderProtocol,
        metadataProvider: (any LogMetadataProvider)? = nil,
        onInternalLog: InternalLog? = nil
    ) {
        self.id = id
        self.logger = logger
        self.executionMethod = executionMethod
        self.filters = filters
        self.encoder = encoder
        self.metadataProvider = metadataProvider
        self.onInternalLog = onInternalLog
    }
    
    // MARK: - Methods(public)
    
    public func log(_ entity: LogEntity) {
        executionMethod.perform { [weak self] in
            guard let self else {
                return
            }
            
            do {
                try self.logInternal(entity)
            }
            catch {
                let message = "Failed to log entity: \(entity). Error: \(error.localizedDescription)"
                self.onInternalLog?(message)
            }
        }
    }
    
    // MARK: - Methods(private)
    
    private func logInternal(_ entity: LogEntity) throws {
        for filter in filters where filter.shouldIgnoreLog(entity) {
            onInternalLog?("Log entity ignored by filter: \(filter.typeName) in destination: \(self.typeName)")
            return
        }
        
        var entityToLog = entity
        
        if let metadataProvider {
            entityToLog.extraInfo.merge(metadataProvider.metadata) { entityValue, _ in entityValue }
        }
        
        let encodedMessage = try encoder.encode(entityToLog)
        let osLogType = mapLogLevelToOSLogType(entity.logLevel)
        
        logger.log(level: osLogType, "\(encodedMessage)")
    }
    
    private func mapLogLevelToOSLogType(_ level: LogLevel) -> OSLogType {
        switch level {
        case .debug:
            return .debug

        case .info:
            return .info

        case .warning:
            return .default

        case .error:
            return .error

        case .critical:
            return .fault
        }
    }
}
