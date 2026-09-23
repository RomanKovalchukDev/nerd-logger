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
    
    // MARK: - Logger Tests
    
    @Suite("Logger")
    struct LoggingTests {
        
        @Test func testInitWhenDestinationsProvidedShouldStoreCorrectly() {
            // Arrange
            let destination1 = TestData.createTestDestination(id: "dest1")
            let destination2 = TestData.createTestDestination(id: "dest2")
            let destinations = [destination1, destination2]
            
            // Act
            let logger = NerdLogger(destinations: destinations)
            
            // Assert
            #expect(logger.destinations.count == 2)
        }
        
        @Test func testAddDestinationWhenNewDestinationShouldAdd() {
            // Arrange
            let initialDestination = TestData.createTestDestination(id: "initial")
            let logger = NerdLogger(destinations: [initialDestination])
            let newDestination = TestData.createTestDestination(id: "new")
            let expectedCount = 2
            
            // Act
            logger.addDestination(newDestination)

            // Assert
            #expect(logger.destinations.count == expectedCount)
        }

        @Test func testAddDestinationWhenDuplicateIdShouldNotAdd() {
            // Arrange
            let destinationId = "duplicate"
            let destination1 = TestData.createTestDestination(id: destinationId)
            let logger = NerdLogger(destinations: [destination1])
            let destination2 = TestData.createTestDestination(id: destinationId)
            let expectedCount = 1
            
            // Act
            logger.addDestination(destination2)

            // Assert
            #expect(logger.destinations.count == expectedCount)
        }

        @Test func testRemoveDestinationWithIDWhenExistsShouldRemove() {
            // Arrange
            let destinationId = "toRemove"
            let destination = TestData.createTestDestination(id: destinationId)
            let logger = NerdLogger(destinations: [destination])
            let expectedCount = 0
            
            // Act
            logger.removeDestinationWithID(destinationId)

            // Assert
            #expect(logger.destinations.count == expectedCount)
        }

        @Test func testRemoveDestinationWithIDWhenNotExistsShouldDoNothing() {
            // Arrange
            let destination = TestData.createTestDestination(id: "existing")
            let logger = NerdLogger(destinations: [destination])
            let nonExistentId = "nonExistent"
            let expectedCount = 1
            
            // Act
            logger.removeDestinationWithID(nonExistentId)

            // Assert
            #expect(logger.destinations.count == expectedCount)
        }

        @Test func testRemoveAllDestinationsShouldClearAll() {
            // Arrange
            let destination1 = TestData.createTestDestination(id: "dest1")
            let destination2 = TestData.createTestDestination(id: "dest2")
            let destination3 = TestData.createTestDestination(id: "dest3")
            let logger = NerdLogger(destinations: [destination1, destination2, destination3])
            let expectedCount = 0
            
            // Act
            logger.removeAllDestinations()

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
            let logger = NerdLogger(destinations: [destination])
            
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
            let logger = NerdLogger(destinations: [destination1, destination2])
            
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
            let logger = NerdLogger(destinations: [fileDestination])
            
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
            let logger = NerdLogger(destinations: [fileDestination])
            
            // Act & Assert - should not throw
            logger.setupAllDestinations()
            logger.flushAllDestinations()
            
            // Cleanup
            let fileURL = containerURL.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testDestinationsWhenAccessedConcurrentlyShouldBeThreadSafe() {
            // Arrange
            let logger = NerdLogger(destinations: [])
            let iterationCount = 10
            
            // Act - concurrent access
            DispatchQueue.concurrentPerform(iterations: iterationCount) { index in
                let destination = TestData.createTestDestination(id: "dest-\(index)")
                logger.addDestination(destination)
                _ = logger.destinations
            }

            // Assert
            #expect(logger.destinations.count <= iterationCount)
        }
        
        @Test(.timeLimit(.minutes(1)))
        func testDestinationsWhenReadFromSaturatedCooperativePoolShouldNotDeadlock() async {
            // Arrange
            let logger = NerdLogger(destinations: [])
            let taskCount = ProcessInfo.processInfo.activeProcessorCount * 2
            
            // Act
            await withTaskGroup(of: Void.self) { group in
                for index in 0..<taskCount {
                    group.addTask {
                        logger.addDestination(TestData.createTestDestination(id: "dest-\(index)"))
                        _ = logger.destinations
                    }
                }
            }
            
            // Assert
            #expect(logger.destinations.count <= taskCount)
        }
    }
}
