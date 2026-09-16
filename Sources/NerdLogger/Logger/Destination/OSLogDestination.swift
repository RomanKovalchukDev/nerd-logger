//
//  OSLogDestination.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation
import os.log

/// A ``LogDestinationProtocol`` implementation that forwards encoded records to Apple's unified logging system via `os.Logger`.
///
/// ``LogLevel`` values are mapped to `OSLogType` so that error and critical records are persisted
/// by `logd`, while lower-severity records use `.default` to remain visible in Console.app without
/// requiring per-subsystem `log config` overrides.
public final class OSLogDestination: LogDestinationProtocol, TypeNameProtocol {

    // MARK: - Properties(public)

    /// Unique identifier for this destination.
    public let id: String
    /// Filters applied to each record before it is forwarded to `os.Logger`.
    public var filters: [any LogFilterProtocol]
    /// Encoder that converts a ``LogEntity`` to the string passed to `os.Logger`.
    public var encoder: any LogEncoderProtocol
    /// Optional provider that merges additional metadata into each record before encoding.
    public var metadataProvider: (any LogMetadataProvider)?
    
    // MARK: - Properties(private)
    
    private let logger: os.Logger
    private let executionMethod: ExecutionMethod
    private let onInternalLog: InternalLog?
    
    // MARK: - Life cycle
    
    /// Creates an OS log destination.
    /// - Parameters:
    ///   - id: Unique identifier for this destination.
    ///   - logger: The `os.Logger` instance that receives formatted records.
    ///   - executionMethod: Synchronization strategy for concurrent callers.
    ///   - filters: Filters applied before encoding. A record is dropped if any filter matches.
    ///   - encoder: Encoder that converts a ``LogEntity`` to a string.
    ///   - metadataProvider: Optional provider that appends extra key-value pairs to each record.
    ///   - onInternalLog: Optional closure that receives diagnostic messages from the destination itself.
    public init(
        id: String,
        logger: os.Logger,
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

    /// Encodes `entity` and forwards it to `os.Logger` at the appropriate `OSLogType`.
    /// - Parameter entity: The log record to write to the unified logging system.
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
        
        logger.log(level: osLogType, "\(encodedMessage, privacy: .public)")
    }
    
    private func mapLogLevelToOSLogType(_ level: LogLevel) -> OSLogType {
        // `.debug` and `.info` are filtered out by Console.app's default stream and
        // not persisted by `logd` unless explicitly enabled per-subsystem. Map them
        // up to `.default` so the tunnel's info-level traces show without needing
        // `log stream --info --debug` or a `log config` override.
        switch level {
        case .debug:
            return .default

        case .info:
            return .default

        case .warning:
            return .default

        case .error:
            return .error

        case .critical:
            return .fault
        }
    }
}
