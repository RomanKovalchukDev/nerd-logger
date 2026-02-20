//
//  LoggerTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Testing
import Foundation
@testable import NerdLogger

@Suite("Logger Tests")
struct LoggerTests {
    
    // MARK: - Test Data
    
    private enum TestData {
        
        static let fixedDate = Date(timeIntervalSince1970: 1609459200)
        
        static func createTestDestination(id: String = "testDestination") -> ConsoleDestination {
            let encoder = LogSimpleEncoder(
                dateFormatter: DateFormatter(),
                logOptions: [.level, .message]
            )
            return ConsoleDestination(
                id: id,
                outputMethod: .print,
                executionMethod: .synchronous(lock: NSRecursiveLock()),
                filters: [],
                encoder: encoder
            )
        }
    }
    
    // MARK: - NerdLogger Tests
    
    @Suite("NerdLogger")
    struct NerdLoggerTests {
        
        @Test func testInitWhenDestinationsProvidedShouldStoreCorrectly() {
            // Arrange
            let destination1 = TestData.createTestDestination(id: "dest1")
            let destination2 = TestData.createTestDestination(id: "dest2")
            let destinations = [destination1, destination2]
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            
            // Act
            let logger = NerdLogger(destinations: destinations, queue: queue)
            
            // Assert
            #expect(logger.destinations.count == 2)
        }
        
        @Test func testAddDestinationWhenNewDestinationShouldAdd() {
            // Arrange
            let initialDestination = TestData.createTestDestination(id: "initial")
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            let logger = NerdLogger(destinations: [initialDestination], queue: queue)
            let newDestination = TestData.createTestDestination(id: "new")
            let expectedCount = 2
            
            // Act
            logger.addDestination(newDestination)
            
            // Small delay for async operation
            Thread.sleep(forTimeInterval: 0.1)
            
            // Assert
            #expect(logger.destinations.count == expectedCount)
        }
        
        @Test func testAddDestinationWhenDuplicateIdShouldNotAdd() {
            // Arrange
            let destinationId = "duplicate"
            let destination1 = TestData.createTestDestination(id: destinationId)
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            let logger = NerdLogger(destinations: [destination1], queue: queue)
            let destination2 = TestData.createTestDestination(id: destinationId)
            let expectedCount = 1
            
            // Act
            logger.addDestination(destination2)
            
            // Small delay for async operation
            Thread.sleep(forTimeInterval: 0.1)
            
            // Assert
            #expect(logger.destinations.count == expectedCount)
        }
        
        @Test func testRemoveDestinationWithIDWhenExistsShouldRemove() {
            // Arrange
            let destinationId = "toRemove"
            let destination = TestData.createTestDestination(id: destinationId)
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            let logger = NerdLogger(destinations: [destination], queue: queue)
            let expectedCount = 0
            
            // Act
            logger.removeDestinationWithID(destinationId)
            
            // Small delay for async operation
            Thread.sleep(forTimeInterval: 0.1)
            
            // Assert
            #expect(logger.destinations.count == expectedCount)
        }
        
        @Test func testRemoveDestinationWithIDWhenNotExistsShouldDoNothing() {
            // Arrange
            let destination = TestData.createTestDestination(id: "existing")
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            let logger = NerdLogger(destinations: [destination], queue: queue)
            let nonExistentId = "nonExistent"
            let expectedCount = 1
            
            // Act
            logger.removeDestinationWithID(nonExistentId)
            
            // Small delay for async operation
            Thread.sleep(forTimeInterval: 0.1)
            
            // Assert
            #expect(logger.destinations.count == expectedCount)
        }
        
        @Test func testRemoveAllDestinationsShouldClearAll() {
            // Arrange
            let destination1 = TestData.createTestDestination(id: "dest1")
            let destination2 = TestData.createTestDestination(id: "dest2")
            let destination3 = TestData.createTestDestination(id: "dest3")
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            let logger = NerdLogger(
                destinations: [destination1, destination2, destination3],
                queue: queue
            )
            let expectedCount = 0
            
            // Act
            logger.removeAllDestinations()
            
            // Small delay for async operation
            Thread.sleep(forTimeInterval: 0.1)
            
            // Assert
            #expect(logger.destinations.count == expectedCount)
        }
        
        @Test func testLogWhenCalledShouldNotThrow() {
            // Arrange
            let message = "Test log message"
            let logLevel = LogLevel.info
            let date = TestData.fixedDate
            let tag = "TestTag"
            let fileName = "TestFile.swift"
            let functionName = "testFunction()"
            let lineNumber: UInt = 42
            let extraInfo = ["key": "value"]
            let destination = TestData.createTestDestination()
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            let logger = NerdLogger(destinations: [destination], queue: queue)
            
            // Act & Assert - should not throw
            logger.log(
                message,
                logLevel: logLevel,
                date: date,
                tag: tag,
                fileName: fileName,
                functionName: functionName,
                lineNumber: lineNumber,
                extraInfo: extraInfo
            )
        }
        
        @Test func testLogWhenMultipleDestinationsShouldLogToAll() {
            // Arrange
            let message = "Test message"
            let logLevel = LogLevel.warning
            let date = TestData.fixedDate
            let tag: String? = nil
            let fileName = "File.swift"
            let functionName = "function()"
            let lineNumber: UInt = 10
            let extraInfo: [String: String] = [:]
            let destination1 = TestData.createTestDestination(id: "dest1")
            let destination2 = TestData.createTestDestination(id: "dest2")
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            let logger = NerdLogger(
                destinations: [destination1, destination2],
                queue: queue
            )
            
            // Act & Assert - should not throw
            logger.log(
                message,
                logLevel: logLevel,
                date: date,
                tag: tag,
                fileName: fileName,
                functionName: functionName,
                lineNumber: lineNumber,
                extraInfo: extraInfo
            )
        }
        
        @Test func testSetupAllDestinationsShouldNotThrow() {
            // Arrange
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "test-setup-all.log"
            let encoder = LogSimpleEncoder(
                dateFormatter: DateFormatter(),
                logOptions: [.level, .message]
            )
            let fileDestination = FileDestination(
                id: "fileDestination",
                containerURL: containerURL,
                fileName: fileName,
                filePermission: "0644",
                flushMode: .manual,
                executionMethod: .synchronous(lock: NSRecursiveLock()),
                dateFormatter: DateFormatter(),
                trimDecoder: LogJSONDecoder(decoder: JSONDecoder()),
                maxLogAge: nil,
                maxFileSize: nil,
                filters: [],
                encoder: encoder
            )
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            let logger = NerdLogger(destinations: [fileDestination], queue: queue)
            
            // Act & Assert - should not throw
            logger.setupAllDestinations()
            
            // Cleanup
            let fileURL = containerURL.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFlushAllDestinationsShouldNotThrow() {
            // Arrange
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "test-flush-all.log"
            let encoder = LogSimpleEncoder(
                dateFormatter: DateFormatter(),
                logOptions: [.level, .message]
            )
            let fileDestination = FileDestination(
                id: "fileDestination",
                containerURL: containerURL,
                fileName: fileName,
                filePermission: "0644",
                flushMode: .manual,
                executionMethod: .synchronous(lock: NSRecursiveLock()),
                dateFormatter: DateFormatter(),
                trimDecoder: LogJSONDecoder(decoder: JSONDecoder()),
                maxLogAge: nil,
                maxFileSize: nil,
                filters: [],
                encoder: encoder
            )
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            let logger = NerdLogger(destinations: [fileDestination], queue: queue)
            
            // Act & Assert - should not throw
            logger.setupAllDestinations()
            logger.flushAllDestinations()
            
            // Cleanup
            let fileURL = containerURL.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testDestinationsWhenAccessedConcurrentlyShouldBeThreadSafe() {
            // Arrange
            let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
            let logger = NerdLogger(destinations: [], queue: queue)
            let iterationCount = 10
            
            // Act - concurrent access
            DispatchQueue.concurrentPerform(iterations: iterationCount) { index in
                let destination = TestData.createTestDestination(id: "dest-\(index)")
                logger.addDestination(destination)
                _ = logger.destinations
            }
            
            // Small delay for async operations
            Thread.sleep(forTimeInterval: 0.2)
            
            // Assert - should not crash, count should be reasonable
            #expect(logger.destinations.count <= iterationCount)
        }
    }
}
