//
//  NerdLogger.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation

/// Default ``LogProtocol`` implementation that fans out records to a mutable set of destinations.
///
/// Destination mutations are serialized through a barrier on the provided queue so registration
/// and enumeration remain thread-safe. Each `log` call builds a ``LogEntity`` (including thread
/// info) and forwards it to a snapshot of the destinations list.
public final class NerdLogger: LogProtocol {
    
    // MARK: - Properties(public)
    
    /// The currently registered destinations, in registration order.
    public var destinations: [any LogDestinationProtocol] {
        queue.sync { _destinations }
    }
    
    // MARK: - Properties(private)
    
    private var _destinations: [any LogDestinationProtocol] = []
    private let queue: DispatchQueue

    // MARK: - Life cycle

    /// Creates a log manager with an initial destination list.
    /// - Parameters:
    ///   - destinations: Destinations that should receive every subsequent log call.
    ///   - queue: Serial or concurrent queue used to synchronize destination-list mutations.
    public init(
        destinations: [any LogDestinationProtocol],
        queue: DispatchQueue
    ) {
        self._destinations = destinations
        self.queue = queue
    }
    
    // MARK: - Methods(public)
    
    /// Registers `destination`, ignoring it silently if a destination with the same ``LogDestinationProtocol/id`` is already registered.
    /// - Parameter destination: The destination to add.
    public func addDestination(_ destination: any LogDestinationProtocol) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else {
                return
            }
            
            guard !self._destinations.contains(where: { $0.id == destination.id }) else {
                return
            }
            
            self._destinations.append(destination)
        }
    }
    
    /// Removes the destination whose ``LogDestinationProtocol/id`` matches `id`, if present.
    /// - Parameter id: The identifier of the destination to remove.
    public func removeDestinationWithID(_ id: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?._destinations.removeAll(where: { $0.id == id })
        }
    }
    
    /// Removes every registered destination.
    public func removeAllDestinations() {
        queue.async(flags: .barrier) { [weak self] in
            self?._destinations.removeAll()
        }
    }
    
    /// Builds a ``LogEntity`` from the supplied parameters and forwards it to all registered destinations.
    /// - Parameters:
    ///   - message: The message body.
    ///   - logLevel: Severity of the record.
    ///   - date: Timestamp associated with the record.
    ///   - tag: Optional grouping label.
    ///   - fileName: Source file that produced the record.
    ///   - functionName: Function that produced the record.
    ///   - lineNumber: Line number of the call site.
    ///   - extraInfo: Arbitrary key-value metadata attached to the record.
    // swiftlint:disable:next function_parameter_count
    public func log(
        _ message: String,
        logLevel: LogLevel,
        date: Date,
        tag: String?,
        fileName: String,
        functionName: String,
        lineNumber: UInt,
        extraInfo: [String: String]
    ) {
        let threadInfo = getThreadInfoString()
        
        let entity = LogEntity(
            logLevel: logLevel,
            message: message,
            tag: tag,
            date: date,
            functionName: functionName,
            fileName: fileName,
            lineNumber: lineNumber,
            thread: threadInfo,
            extraInfo: extraInfo
        )
        
        let destinationsSnapshot = queue.sync { _destinations }
        
        for destination in destinationsSnapshot {
            destination.log(entity)
        }
    }
    
    /// Calls `setup()` on every registered ``PersistedLogDestinationProtocol`` destination.
    public func setupAllDestinations() {
        let destinationsSnapshot = queue.sync { _destinations }
        
        for destination in destinationsSnapshot {
            if let persistedDestination = destination as? PersistedLogDestinationProtocol {
                persistedDestination.setup()
            }
        }
    }
    
    /// Calls `flush()` on every registered ``PersistedLogDestinationProtocol`` destination.
    public func flushAllDestinations() {
        let destinationsSnapshot = queue.sync { _destinations }
        
        for destination in destinationsSnapshot {
            if let persistedDestination = destination as? PersistedLogDestinationProtocol {
                persistedDestination.flush()
            }
        }
    }
    
    // MARK: - Methods(private)
    
    private func getThreadInfoString() -> String {
        let isMain = Thread.isMainThread
        let threadName = Thread.current.name ?? ""
        let threadID = Thread.threadId
        let dispatchQueueLabel = DispatchQueue.currentLabel
        
        return "ThreadInfo: isMain:\(isMain); name:\(threadName); id:\(threadID); queue:\(dispatchQueueLabel)"
    }
}
