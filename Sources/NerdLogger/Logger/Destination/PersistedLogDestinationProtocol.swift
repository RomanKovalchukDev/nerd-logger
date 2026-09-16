//
//  PersistedLogDestinationProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

/// A ``LogDestinationProtocol`` that persists records to durable storage and supports explicit flushing.
///
/// Implementations typically open a file handle on `setup()` and flush buffered writes on `flush()`.
/// ``NerdLogger`` calls these methods in bulk via ``LogProtocol/setupAllDestinations()`` and
/// ``LogProtocol/flushAllDestinations()``.
public protocol PersistedLogDestinationProtocol: LogDestinationProtocol {
    /// Prepares the destination for writing (for example, opens the log file and schedules rotation timers).
    func setup()

    /// Forces any buffered log entries to be written to the underlying storage.
    func flush()
}
