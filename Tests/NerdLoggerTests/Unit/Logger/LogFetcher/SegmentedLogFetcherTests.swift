//
//  SegmentedLogFetcherTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 06.07.2026.
//

import Testing
import Foundation
@testable import NerdLogger

@Suite("SegmentedLogFetcher Tests")
struct SegmentedLogFetcherTests {

    // MARK: - Test Helpers

    private static func makeSegmentFile(directory: URL, name: String, content: String) throws -> URL {
        let url = directory.appendingPathComponent(name)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func makeDecoderMock() -> LogDecoderProtocolMock {
        let mock = LogDecoderProtocolMock()
        // Default: split on newlines
        mock.splitContentContentStringStringClosure = { content in
            content.split(separator: "\n").map(String.init)
        }
        return mock
    }

    // MARK: - fetchLogs

    @Test("fetchLogs merges entries from all segment files sorted by date")
    func testFetchLogsMergesEntriesFromAllSegmentFilesSortedByDate() throws {
        // Arrange
        let dir = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(dir) }
        let firstURL = try Self.makeSegmentFile(directory: dir, name: "seg1", content: "a\nb")
        let secondURL = try Self.makeSegmentFile(directory: dir, name: "seg2", content: "c")
        let dateNow = Date()
        let dateOlder = dateNow.addingTimeInterval(-100)
        let dateEven = dateNow.addingTimeInterval(-200)
        let fileManager = LogFileManagerProtocolFake()
        fileManager.sortedLogFileURLsResult = [firstURL, secondURL]
        let decoder = Self.makeDecoderMock()
        decoder.decodeStringStringLogEntityClosure = { line in
            switch line {
            case "a":
                return LogEntity(logLevel: .info, message: "a", date: dateOlder)
            case "b":
                return LogEntity(logLevel: .info, message: "b", date: dateEven)
            case "c":
                return LogEntity(logLevel: .info, message: "c", date: dateNow)
            default:
                return nil
            }
        }
        let sut = SegmentedLogFetcher(fileManager: fileManager, decoder: decoder)

        // Act
        let result = try sut.fetchLogs(with: nil)

        // Assert
        #expect(result.map(\.message) == ["b", "a", "c"])
    }

    @Test("fetchLogs applies filter when provided")
    func testFetchLogsAppliesFilterWhenProvided() throws {
        // Arrange
        let dir = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(dir) }
        let segURL = try Self.makeSegmentFile(directory: dir, name: "seg", content: "keep\ndrop")
        let fileManager = LogFileManagerProtocolFake()
        fileManager.sortedLogFileURLsResult = [segURL]
        let decoder = Self.makeDecoderMock()
        decoder.decodeStringStringLogEntityClosure = { line in
            LogEntity(logLevel: .info, message: line, date: Date())
        }
        let sut = SegmentedLogFetcher(fileManager: fileManager, decoder: decoder)

        // Act
        let result = try sut.fetchLogs(with: { $0.message == "keep" })

        // Assert
        #expect(result.map(\.message) == ["keep"])
    }

    @Test("fetchLogs skips unreadable segment files")
    func testFetchLogsSkipsUnreadableSegmentFiles() throws {
        // Arrange
        let dir = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(dir) }
        let goodURL = try Self.makeSegmentFile(directory: dir, name: "good", content: "x")
        let missingURL = dir.appendingPathComponent("missing")
        let fileManager = LogFileManagerProtocolFake()
        fileManager.sortedLogFileURLsResult = [missingURL, goodURL]
        let decoder = Self.makeDecoderMock()
        decoder.decodeStringStringLogEntityClosure = { line in
            LogEntity(logLevel: .info, message: line, date: Date())
        }
        let sut = SegmentedLogFetcher(fileManager: fileManager, decoder: decoder)

        // Act
        let result = try sut.fetchLogs(with: nil)

        // Assert
        #expect(result.map(\.message) == ["x"])
    }

    @Test("fetchLogs skips lines when decoder returns nil")
    func testFetchLogsSkipsLinesWhenDecoderReturnsNil() throws {
        // Arrange
        let dir = FileTestHelpers.createTemporaryDirectory()
        defer { FileTestHelpers.cleanup(dir) }
        let segURL = try Self.makeSegmentFile(directory: dir, name: "seg", content: "keep\nskip")
        let fileManager = LogFileManagerProtocolFake()
        fileManager.sortedLogFileURLsResult = [segURL]
        let decoder = Self.makeDecoderMock()
        decoder.decodeStringStringLogEntityClosure = { line in
            line == "skip" ? nil : LogEntity(logLevel: .info, message: line, date: Date())
        }
        let sut = SegmentedLogFetcher(fileManager: fileManager, decoder: decoder)

        // Act
        let result = try sut.fetchLogs(with: nil)

        // Assert
        #expect(result.map(\.message) == ["keep"])
    }

    @Test("fetchLogs when no segment files returns empty")
    func testFetchLogsWhenNoSegmentFilesReturnsEmpty() throws {
        // Arrange
        let fileManager = LogFileManagerProtocolFake()
        fileManager.sortedLogFileURLsResult = []
        let decoder = Self.makeDecoderMock()
        let sut = SegmentedLogFetcher(fileManager: fileManager, decoder: decoder)

        // Act
        let result = try sut.fetchLogs(with: nil)

        // Assert
        #expect(result.isEmpty)
    }
}
