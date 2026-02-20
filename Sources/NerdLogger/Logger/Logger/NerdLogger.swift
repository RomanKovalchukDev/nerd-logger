//
//  NerdLogger.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

// swiftlint:disable function_parameter_count

import Foundation

public final class NerdLogger: LogProtocol {
    
    // MARK: - Properties(public)
    
    public var destinations: [any LogDestinationProtocol] {
        queue.sync { _destinations }
    }
    
    // MARK: - Properties(private)
    
    private var _destinations: [any LogDestinationProtocol] = []
    private let queue: DispatchQueue
    
    // MARK: - Life cycle
    
    public init(
        destinations: [any LogDestinationProtocol],
        queue: DispatchQueue
    ) {
        self._destinations = destinations
        self.queue = queue
    }
    
    // MARK: - Methods(public)
    
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
    
    public func removeDestinationWithID(_ id: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?._destinations.removeAll(where: { $0.id == id })
        }
    }
    
    public func removeAllDestinations() {
        queue.async(flags: .barrier) { [weak self] in
            self?._destinations.removeAll()
        }
    }
    
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
    
    public func setupAllDestinations() {
        let destinationsSnapshot = queue.sync { _destinations }
        
        for destination in destinationsSnapshot {
            if let persistedDestination = destination as? PersistedLogDestinationProtocol {
                persistedDestination.setup()
            }
        }
    }
    
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
