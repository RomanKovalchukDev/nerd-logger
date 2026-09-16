//
//  LogFileManagerProtocolFake.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 06.07.2026.
//
//  Hand-crafted fake for `LogFileManagerProtocol`. Sourcery's `AutoMockable`
//  template currently emits duplicate `typeName` declarations for protocols
//  that inherit from ``TypeNameProtocol``, so mocks for closely-related types
//  are curated by hand here to keep the test target buildable.
//

import Foundation
@testable import NerdLogger

/// Configurable stand-in for ``LogFileManagerProtocol`` used by fetcher tests.
final class LogFileManagerProtocolFake: LogFileManagerProtocol, @unchecked Sendable {
    var containerURL: URL = FileManager.default.temporaryDirectory
    var baseFileName: String = "app.log"
    var maxFileCount: Int?
    var maxTotalSize: Int?
    var isRolling: Bool = false

    var sortedLogFileURLsResult: [URL] = []
    var currentFileURLResult: URL = FileManager.default.temporaryDirectory.appendingPathComponent("app.log")
    var nextRotationDateResult: Date?

    private(set) var sortedLogFileURLsCalls = 0
    private(set) var ensureCurrentFileExistsCalls = 0
    private(set) var cleanupOldFilesCalls = 0
    private(set) var deleteAllFilesCalls = 0

    var ensureCurrentFileExistsError: (any Error)?
    var deleteAllFilesError: (any Error)?

    func currentFileURL() -> URL {
        currentFileURLResult
    }

    func nextRotationDate() -> Date? {
        nextRotationDateResult
    }

    func sortedLogFileURLs() -> [URL] {
        sortedLogFileURLsCalls += 1
        return sortedLogFileURLsResult
    }

    func ensureCurrentFileExists(permission: String) throws {
        ensureCurrentFileExistsCalls += 1
        if let ensureCurrentFileExistsError {
            throw ensureCurrentFileExistsError
        }
    }

    func cleanupOldFiles() {
        cleanupOldFilesCalls += 1
    }

    func deleteAllFiles() throws {
        deleteAllFilesCalls += 1
        if let deleteAllFilesError {
            throw deleteAllFilesError
        }
    }
}
