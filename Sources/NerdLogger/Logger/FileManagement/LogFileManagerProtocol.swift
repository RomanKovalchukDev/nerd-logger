//
//  LogFileManagerProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 22.04.2026.
//

import Foundation

/// Abstraction for log file management: naming, rotation, enumeration, and cleanup.
///
/// Consumers (`FileDestination`, `SegmentedLogFetcher`) depend on this protocol
/// rather than the concrete `LogFileManager`, enabling testability with mocks.
public protocol LogFileManagerProtocol {
    /// Directory where log files are created.
    var containerURL: URL { get }
    /// Base file name used to derive segment file names (for example `"app.log"`).
    var baseFileName: String { get }
    /// Maximum number of segment files to retain. `nil` means unlimited.
    var maxFileCount: Int? { get }
    /// Maximum total size in bytes for all segment files. `nil` means unlimited.
    var maxTotalSize: Int? { get }
    /// `true` when file rolling is active.
    var isRolling: Bool { get }

    /// Returns the URL to write to right now.
    func currentFileURL() -> URL

    /// The date at which the current segment expires and a new file should be opened.
    /// Returns `nil` when rolling is disabled.
    func nextRotationDate() -> Date?

    /// All log file URLs matching this manager's naming pattern, sorted oldest-first.
    func sortedLogFileURLs() -> [URL]

    /// Ensures the current file and its parent directory exist.
    func ensureCurrentFileExists(permission: String) throws

    /// Removes old segment files based on age and size constraints.
    func cleanupOldFiles()

    /// Deletes all log files matching this manager's pattern.
    func deleteAllFiles() throws
}
