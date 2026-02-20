//
//  ConsoleDestination.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation

public final class ConsoleDestination: LogDestinationProtocol {
    
    // MARK: - Internal types
    
    public enum OutputMethod {
        case debugPrint
        case print
        case nsLog
    }
    
    // MARK: - Properties(public)
    
    public let id: String
    public var filters: [any LogFilterProtocol]
    public let encoder: any LogEncoderProtocol
    public var metadataProvider: (any LogMetadataProvider)?
    
    // MARK: - Properties(private)
    
    private let outputMethod: OutputMethod
    private let executionMethod: ExecutionMethod
    private let onInternalLog: InternalLog?
    
    // MARK: - Life cycle
    
    public init(
        id: String,
        outputMethod: OutputMethod,
        executionMethod: ExecutionMethod,
        filters: [any LogFilterProtocol],
        encoder: any LogEncoderProtocol,
        metadataProvider: (any LogMetadataProvider)? = nil,
        onInternalLog: InternalLog? = nil
    ) {
        self.id = id
        self.outputMethod = outputMethod
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
        
        switch outputMethod {
        case .debugPrint:
            debugPrint(encodedMessage)

        case .print:
            print(encodedMessage)

        case .nsLog:
            NSLog("%@", encodedMessage)
        }
    }
}

extension ConsoleDestination: TypeNameProtocol {}
