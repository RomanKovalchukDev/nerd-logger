//
//  LogFileManagerTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 06.07.2026.
//

import Testing
import Foundation
@testable import NerdLogger

@Suite("LogFileManager Tests")
struct LogFileManagerTests {

    // MARK: - Test Helpers

    private static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }

    // MARK: - segmentedFileName

    @Test("segmentedFileName inserts date before extension")
    func testSegmentedFileNameInsertsDateBeforeExtension() {
        // Arrange
        let baseName = "app.log"
        let dateString = "2026-04-22"

        // Act
        let result = LogFileManager.segmentedFileName(baseName: baseName, dateString: dateString)

        // Assert
        #expect(result == "app_2026-04-22.log")
    }

    @Test("segmentedFileName appends date when no extension present")
    func testSegmentedFileNameAppendsDateWhenNoExtension() {
        // Arrange
        let baseName = "app"
        let dateString = "2026-04-22"

        // Act
        let result = LogFileManager.segmentedFileName(baseName: baseName, dateString: dateString)

        // Assert
        #expect(result == "app_2026-04-22")
    }

    // MARK: - isRolling

    @Test("isRolling is false when rollingFrequency nil")
    func testIsRollingFalseWhenRollingFrequencyNil() {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }

        // Act
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: nil
        )

        // Assert
        #expect(sut.isRolling == false)
    }

    @Test("isRolling is true when rollingFrequency positive")
    func testIsRollingTrueWhenRollingFrequencyPositive() {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }

        // Act
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: 86_400
        )

        // Assert
        #expect(sut.isRolling == true)
    }

    // MARK: - currentFileURL

    @Test("currentFileURL when not rolling returns base file")
    func testCurrentFileURLWhenNotRollingReturnsBaseFile() {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: nil
        )

        // Act
        let url = sut.currentFileURL()

        // Assert
        #expect(url == containerURL.appendingPathComponent("app.log"))
    }

    @Test("currentFileURL when rolling includes date segment")
    func testCurrentFileURLWhenRollingIncludesDateSegment() {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let formatter = Self.makeDateFormatter()
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: formatter,
            rollingFrequency: 86_400
        )

        // Act
        let url = sut.currentFileURL()

        // Assert
        let expectedSuffix = "_\(formatter.string(from: Date())).log"
        #expect(url.lastPathComponent.hasSuffix(expectedSuffix))
    }

    // MARK: - nextRotationDate

    @Test("nextRotationDate returns nil when not rolling")
    func testNextRotationDateReturnsNilWhenNotRolling() {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: nil
        )

        // Act
        let result = sut.nextRotationDate()

        // Assert
        #expect(result == nil)
    }

    @Test("nextRotationDate returns future date when rolling")
    func testNextRotationDateReturnsFutureDateWhenRolling() throws {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: 86_400
        )

        // Act
        let result = try #require(sut.nextRotationDate())

        // Assert
        #expect(result > Date())
    }

    // MARK: - ensureCurrentFileExists

    @Test("ensureCurrentFileExists creates file and directory")
    func testEnsureCurrentFileExistsCreatesFileAndDirectory() throws {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory().appendingPathComponent("nested")
        defer { FileTestHelpers.cleanup(containerURL.deletingLastPathComponent()) }
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: nil
        )

        // Act
        try sut.ensureCurrentFileExists(permission: "0644")

        // Assert
        #expect(FileManager.default.fileExists(atPath: containerURL.appendingPathComponent("app.log").path))
    }

    @Test("ensureCurrentFileExists throws for invalid permission")
    func testEnsureCurrentFileExistsThrowsForInvalidPermission() {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: nil
        )

        // Act & Assert
        #expect(throws: FileError.self) {
            try sut.ensureCurrentFileExists(permission: "invalid")
        }
    }

    // MARK: - sortedLogFileURLs

    @Test("sortedLogFileURLs when not rolling returns base file if present")
    func testSortedLogFileURLsWhenNotRollingReturnsBaseFileIfPresent() throws {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: nil
        )
        try sut.ensureCurrentFileExists(permission: "0644")

        // Act
        let urls = sut.sortedLogFileURLs()

        // Assert
        #expect(urls.count == 1)
        #expect(urls.first?.lastPathComponent == "app.log")
    }

    @Test("sortedLogFileURLs returns segment files ordered oldest first")
    func testSortedLogFileURLsReturnsSegmentFilesOrderedOldestFirst() throws {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: 86_400
        )
        let earlyURL = containerURL.appendingPathComponent("app_2026-01-01.log")
        let midURL = containerURL.appendingPathComponent("app_2026-02-01.log")
        let lateURL = containerURL.appendingPathComponent("app_2026-03-01.log")
        for url in [midURL, earlyURL, lateURL] {
            try Data().write(to: url)
        }

        // Act
        let urls = sut.sortedLogFileURLs()

        // Assert
        #expect(urls.map(\.lastPathComponent) == [
            "app_2026-01-01.log",
            "app_2026-02-01.log",
            "app_2026-03-01.log"
        ])
    }

    // MARK: - deleteAllFiles

    @Test("deleteAllFiles removes base file when not rolling")
    func testDeleteAllFilesRemovesBaseFileWhenNotRolling() throws {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: nil
        )
        try sut.ensureCurrentFileExists(permission: "0644")
        #expect(FileManager.default.fileExists(atPath: containerURL.appendingPathComponent("app.log").path))

        // Act
        try sut.deleteAllFiles()

        // Assert
        #expect(!FileManager.default.fileExists(atPath: containerURL.appendingPathComponent("app.log").path))
    }

    @Test("deleteAllFiles removes all segment files when rolling")
    func testDeleteAllFilesRemovesAllSegmentFilesWhenRolling() throws {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: 86_400
        )
        for name in ["app_2026-01-01.log", "app_2026-02-01.log", "unrelated.txt"] {
            try Data().write(to: containerURL.appendingPathComponent(name))
        }

        // Act
        try sut.deleteAllFiles()

        // Assert
        let remaining = try FileManager.default.contentsOfDirectory(atPath: containerURL.path)
        #expect(remaining == ["unrelated.txt"])
    }

    // MARK: - cleanupOldFiles

    @Test("cleanupOldFiles is a no-op when not rolling")
    func testCleanupOldFilesIsANoOpWhenNotRolling() throws {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: Self.makeDateFormatter(),
            rollingFrequency: nil,
            maxFileCount: 1
        )
        let fileURL = containerURL.appendingPathComponent("app.log")
        try Data().write(to: fileURL)

        // Act
        sut.cleanupOldFiles()

        // Assert
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }

    @Test("cleanupOldFiles removes excess segments beyond maxFileCount")
    func testCleanupOldFilesRemovesExcessSegmentsBeyondMaxFileCount() throws {
        // Arrange
        let containerURL = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(containerURL) }
        let formatter = Self.makeDateFormatter()
        let sut = LogFileManager(
            containerURL: containerURL,
            baseFileName: "app.log",
            segmentDateFormatter: formatter,
            rollingFrequency: 86_400,
            maxFileCount: 2
        )
        for name in ["app_2026-01-01.log", "app_2026-02-01.log", "app_2026-03-01.log"] {
            try Data().write(to: containerURL.appendingPathComponent(name))
        }
        // Ensure today's file is not included in the seeded set (it is protected)

        // Act
        sut.cleanupOldFiles()

        // Assert
        let remaining = try FileManager.default.contentsOfDirectory(atPath: containerURL.path).sorted()
        #expect(remaining == ["app_2026-02-01.log", "app_2026-03-01.log"])
    }
}
