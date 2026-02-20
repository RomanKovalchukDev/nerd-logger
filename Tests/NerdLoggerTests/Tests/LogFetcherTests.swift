//
//  LogFetcherTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Testing
import Foundation
@testable import NerdLogger

@Suite("Log Fetcher Tests")
struct LogFetcherTests {
    
    // MARK: - Test Data
    
    private enum TestData {
        
        static let fixedDate = Date(timeIntervalSince1970: 1609459200) // 2021-01-01 00:00:00 UTC
        
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone(identifier: "UTC")
            return formatter
        }()
        
        static func createTestEntity(
            logLevel: LogLevel = .info,
            message: String = "Test message",
            tag: String? = "TestTag",
            date: Date = fixedDate
        ) -> LogEntity {
            return LogEntity(
                logLevel: logLevel,
                message: message,
                tag: tag,
                date: date,
                functionName: "testFunction()",
                fileName: "TestFile.swift",
                lineNumber: 42,
                thread: "main",
                extraInfo: [:]
            )
        }
        
        static func createTestFileWithLogs(fileName: String, entities: [LogEntity]) throws -> URL {
            let containerURL = FileManager.default.temporaryDirectory
            let fileURL = containerURL.appendingPathComponent(fileName)
            
            let encoder = LogCSVEncoder(
                delimiter: ",",
                dateFormatter: dateFormatter,
                logOptions: [.level, .timestamp, .message, .tag]
            )
            
            var content = ""
            for entity in entities {
                let encoded = try encoder.encode(entity)
                content += encoded + "\n"
            }
            
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        }
    }
    
    // MARK: - FileLogFetcher Tests
    
    @Suite("FileLogFetcher")
    struct FileLogFetcherTests {
        
        @Test func testInitWhenParametersProvidedShouldStoreCorrectly() throws {
            // Arrange
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "test-init.log"
            let fileURL = containerURL.appendingPathComponent(fileName)
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .timestamp, .message]
            )
            
            // Act
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: decoder)
            
            // Assert
            #expect(fetcher.decoder is LogCSVDecoder)
            
            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFetchLogsWhenNoFilterShouldReturnAll() throws {
            // Arrange
            let fileName = "test-fetch-all.log"
            let entity1 = TestData.createTestEntity(logLevel: .info, message: "Message 1")
            let entity2 = TestData.createTestEntity(logLevel: .warning, message: "Message 2")
            let entity3 = TestData.createTestEntity(logLevel: .error, message: "Message 3")
            let entities = [entity1, entity2, entity3]
            let fileURL = try TestData.createTestFileWithLogs(fileName: fileName, entities: entities)
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .timestamp, .message, .tag]
            )
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: decoder)
            let expectedCount = 3
            
            // Act
            let fetchedLogs = try fetcher.fetchLogs { _ in true }
            
            // Assert
            #expect(fetchedLogs.count == expectedCount)
            
            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFetchLogsWhenFilterByLogLevelShouldReturnMatching() throws {
            // Arrange
            let fileName = "test-fetch-filter-level.log"
            let entity1 = TestData.createTestEntity(logLevel: .info, message: "Info message")
            let entity2 = TestData.createTestEntity(logLevel: .warning, message: "Warning message")
            let entity3 = TestData.createTestEntity(logLevel: .error, message: "Error message")
            let entities = [entity1, entity2, entity3]
            let fileURL = try TestData.createTestFileWithLogs(fileName: fileName, entities: entities)
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .timestamp, .message, .tag]
            )
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: decoder)
            let targetLevel = LogLevel.error
            let expectedCount = 1
            
            // Act
            let fetchedLogs = try fetcher.fetchLogs { entity in
                entity.logLevel == targetLevel
            }
            
            // Assert
            #expect(fetchedLogs.count == expectedCount)
            #expect(fetchedLogs.first?.logLevel == targetLevel)
            
            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFetchLogsWhenFilterByMessageShouldReturnMatching() throws {
            // Arrange
            let fileName = "test-fetch-filter-message.log"
            let targetMessage = "Important message"
            let entity1 = TestData.createTestEntity(message: "Regular message")
            let entity2 = TestData.createTestEntity(message: targetMessage)
            let entity3 = TestData.createTestEntity(message: "Another message")
            let entities = [entity1, entity2, entity3]
            let fileURL = try TestData.createTestFileWithLogs(fileName: fileName, entities: entities)
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .timestamp, .message, .tag]
            )
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: decoder)
            let expectedCount = 1
            
            // Act
            let fetchedLogs = try fetcher.fetchLogs { entity in
                entity.message.contains("Important")
            }
            
            // Assert
            #expect(fetchedLogs.count == expectedCount)
            #expect(fetchedLogs.first?.message == targetMessage)
            
            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFetchLogsWhenFilterByTagShouldReturnMatching() throws {
            // Arrange
            let fileName = "test-fetch-filter-tag.log"
            let targetTag = "Network"
            let entity1 = TestData.createTestEntity(tag: "Database")
            let entity2 = TestData.createTestEntity(tag: targetTag)
            let entity3 = TestData.createTestEntity(tag: "UI")
            let entities = [entity1, entity2, entity3]
            let fileURL = try TestData.createTestFileWithLogs(fileName: fileName, entities: entities)
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .timestamp, .message, .tag]
            )
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: decoder)
            let expectedCount = 1
            
            // Act
            let fetchedLogs = try fetcher.fetchLogs { entity in
                entity.tag == targetTag
            }
            
            // Assert
            #expect(fetchedLogs.count == expectedCount)
            #expect(fetchedLogs.first?.tag == targetTag)
            
            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFetchLogsWhenEmptyFileShouldReturnEmpty() throws {
            // Arrange
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "test-fetch-empty.log"
            let fileURL = containerURL.appendingPathComponent(fileName)
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .timestamp, .message]
            )
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: decoder)
            let expectedCount = 0
            
            // Act
            let fetchedLogs = try fetcher.fetchLogs { _ in true }
            
            // Assert
            #expect(fetchedLogs.count == expectedCount)
            
            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFetchLogsWhenNoMatchingFilterShouldReturnEmpty() throws {
            // Arrange
            let fileName = "test-fetch-no-match.log"
            let entity1 = TestData.createTestEntity(logLevel: .info)
            let entity2 = TestData.createTestEntity(logLevel: .warning)
            let entities = [entity1, entity2]
            let fileURL = try TestData.createTestFileWithLogs(fileName: fileName, entities: entities)
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .timestamp, .message, .tag]
            )
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: decoder)
            let expectedCount = 0
            
            // Act
            let fetchedLogs = try fetcher.fetchLogs { entity in
                entity.logLevel == .critical
            }
            
            // Assert
            #expect(fetchedLogs.count == expectedCount)
            
            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFetchLogsWhenComplexFilterShouldReturnMatching() throws {
            // Arrange
            let fileName = "test-fetch-complex-filter.log"
            let entity1 = TestData.createTestEntity(logLevel: .info, message: "Info", tag: "Network")
            let entity2 = TestData.createTestEntity(logLevel: .error, message: "Error", tag: "Network")
            let entity3 = TestData.createTestEntity(logLevel: .error, message: "Error", tag: "Database")
            let entities = [entity1, entity2, entity3]
            let fileURL = try TestData.createTestFileWithLogs(fileName: fileName, entities: entities)
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .timestamp, .message, .tag]
            )
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: decoder)
            let targetTag = "Network"
            let targetLevel = LogLevel.error
            let expectedCount = 1
            
            // Act
            let fetchedLogs = try fetcher.fetchLogs { entity in
                entity.logLevel == targetLevel && entity.tag == targetTag
            }
            
            // Assert
            #expect(fetchedLogs.count == expectedCount)
            #expect(fetchedLogs.first?.logLevel == targetLevel)
            #expect(fetchedLogs.first?.tag == targetTag)
            
            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFetchLogsWhenFileNotExistsShouldThrow() {
            // Arrange
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "non-existent.log"
            let fileURL = containerURL.appendingPathComponent(fileName)
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .timestamp, .message]
            )
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: decoder)
            
            // Act & Assert
            #expect(throws: Error.self) {
                try fetcher.fetchLogs { _ in true }
            }
        }
        
        @Test func testDecoderWhenSetShouldUpdate() throws {
            // Arrange
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "test-decoder-update.log"
            let fileURL = containerURL.appendingPathComponent(fileName)
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
            let initialDecoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .message]
            )
            let newDecoder = LogJSONDecoder(decoder: JSONDecoder())
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: initialDecoder)
            
            // Act
            fetcher.decoder = newDecoder
            
            // Assert
            #expect(fetcher.decoder is LogJSONDecoder)
            
            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFetchLogsWhenMultipleFetchesShouldReturnConsistent() throws {
            // Arrange
            let fileName = "test-fetch-multiple.log"
            let entity1 = TestData.createTestEntity(message: "Message 1")
            let entity2 = TestData.createTestEntity(message: "Message 2")
            let entities = [entity1, entity2]
            let fileURL = try TestData.createTestFileWithLogs(fileName: fileName, entities: entities)
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: TestData.dateFormatter,
                logOptions: [.level, .timestamp, .message, .tag]
            )
            let fetcher = FileLogFetcher(fileURL: fileURL, decoder: decoder)
            let expectedCount = 2
            
            // Act
            let firstFetch = try fetcher.fetchLogs { _ in true }
            let secondFetch = try fetcher.fetchLogs { _ in true }
            
            // Assert
            #expect(firstFetch.count == expectedCount)
            #expect(secondFetch.count == expectedCount)
            #expect(firstFetch.count == secondFetch.count)
            
            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}
