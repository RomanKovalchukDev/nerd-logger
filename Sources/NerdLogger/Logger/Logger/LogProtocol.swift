//
//  LogProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 15.09.2025.
//

import Foundation

/// The public entry point for emitting log records and managing their destinations.
///
/// Implementations fan out each log call to every registered ``LogDestinationProtocol``.
/// See ``LogProtocol`` helper extensions for convenience methods like `debug`, `info`, and `error`.
public protocol LogProtocol {
    /// The currently registered destinations, in registration order.
    var destinations: [any LogDestinationProtocol] { get }

    /// Registers a destination, ignoring duplicates that share the same ``LogDestinationProtocol/id``.
    func addDestination(_ destination: any LogDestinationProtocol)

    /// Removes the destination whose ``LogDestinationProtocol/id`` matches `id`, if present.
    func removeDestinationWithID(_ id: String)

    /// Removes every registered destination.
    func removeAllDestinations()

    /// Emits a log record to every registered destination.
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
    func log(
        _ message: String,
        logLevel: LogLevel,
        date: Date,
        tag: String?,
        fileName: String,
        functionName: String,
        lineNumber: UInt,
        extraInfo: [String: String]
    )

    /// Invokes `setup()` on every registered ``PersistedLogDestinationProtocol``.
    func setupAllDestinations()

    /// Invokes `flush()` on every registered ``PersistedLogDestinationProtocol``.
    func flushAllDestinations()
}
