//
//  ConsoleDestination.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation
import os.log

/// A ``LogDestinationProtocol`` implementation that writes encoded log records to the console.
///
/// Supports four output methods selectable at initialization time, ranging from `print` to
/// the unified os.log subsystem.
public final class ConsoleDestination: LogDestinationProtocol {

    // MARK: - Internal types

    /// The low-level function used to emit each encoded log line.
    public enum OutputMethod {
        /// Uses Swift's `debugPrint` function.
        case debugPrint
        /// Uses Swift's `print` function.
        case print
        /// Uses Foundation's `NSLog`.
        case nsLog
        /// Uses `os_log` from the unified logging system.
        case osLog
    }

    // MARK: - Properties(public)

    /// Unique identifier for this destination.
    public let id: String
    /// Filters applied to each record before it is written to the console.
    public var filters: [any LogFilterProtocol]
    /// Encoder that formats each ``LogEntity`` into a printable string.
    public let encoder: any LogEncoderProtocol
    /// Optional provider that merges additional metadata into each record before encoding.
    public var metadataProvider: (any LogMetadataProvider)?
    
    // MARK: - Properties(private)
    
    private let outputMethod: OutputMethod
    private let executionMethod: ExecutionMethod
    private let onInternalLog: InternalLog?
    
    // MARK: - Life cycle
    
    /// Creates a console destination.
    /// - Parameters:
    ///   - id: Unique identifier for this destination.
    ///   - outputMethod: The function used to print each record.
    ///   - executionMethod: Synchronization strategy (lock or serial queue) for concurrent callers.
    ///   - filters: Filters applied before encoding. A record is dropped if any filter matches.
    ///   - encoder: Encoder that converts a ``LogEntity`` to a string.
    ///   - metadataProvider: Optional provider that appends extra key-value pairs to each record.
    ///   - onInternalLog: Optional closure that receives diagnostic messages from the destination itself.
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

    /// Encodes and prints `entity` using the configured output method.
    /// - Parameter entity: The log record to write to the console.
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

        case .osLog:
            os_log("%{public}@", encodedMessage)
        }
    }
}

extension ConsoleDestination: TypeNameProtocol {}
