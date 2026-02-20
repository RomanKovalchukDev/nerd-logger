//
//  ExecutionMethod.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// Defines the two types of execution methods used when logging a message.
///
/// Logging operations can be expensive operations when there are hundreds of messages being generated or when
/// it is computationally expensive to compute the message to log. Ideally, one would use the synchronous method
/// in development, and the asynchronous method in production. This allows for easier debugging in the development
/// environment, and better performance in production.
///
/// - synchronous:  Logs messages synchronously once the recursive lock is available in serial order.
/// - asynchronous: Logs messages asynchronously on the dispatch queue in a serial order.
public enum ExecutionMethod {
    case synchronous(lock: NSRecursiveLock)
    case asynchronous(queue: DispatchQueue)

    /// Performs a block of work using the desired synchronization method (either locks or serial queues).
    /// - Parameter work: An escaping block of work that needs to be protected against data races.
    public func perform(work: @escaping () -> Void) {
        switch self {
        case .synchronous(lock: let lock):
            lock.lock()
            defer { lock.unlock() }
            work()

        case .asynchronous(queue: let queue):
            queue.async { work() }
        }
    }
}
