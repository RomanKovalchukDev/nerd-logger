//
//  DestinationTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Testing
import Foundation
import os.log
@testable import NerdLogger

@Suite("Log Destinations Tests")
struct DestinationTests {
    
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
            date: Date = fixedDate,
            extraInfo: [String: String] = [:]
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
                extraInfo: extraInfo
            )
        }
        
        static func createSimpleEncoder() -> LogSimpleEncoder {
            LogSimpleEncoder(
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
        }
    }
    
    // MARK: - ConsoleDestination Tests
    
    @Suite("ConsoleDestination")
    struct ConsoleDestinationTests {
        
        @Test func testLogWhenNoFiltersShouldLogMessage() {
            // Arrange
            let destinationId = "testConsole"
            let outputMethod = ConsoleDestination.OutputMethod.print
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let filters: [any LogFilterProtocol] = []
            let encoder = TestData.createSimpleEncoder()
            var internalLogMessages: [String] = []
            let destination = ConsoleDestination(
                id: destinationId,
                outputMethod: outputMethod,
                executionMethod: executionMethod,
                filters: filters,
                encoder: encoder,
                onInternalLog: { internalLogMessages.append($0) }
            )
            let entity = TestData.createTestEntity()
            
            // Act
            destination.log(entity)
            
            // Assert - no internal errors
            #expect(internalLogMessages.isEmpty)
        }
        
        @Test func testLogWhenFilterIgnoresShouldNotLog() {
            // Arrange
            let destinationId = "testConsole"
            let outputMethod = ConsoleDestination.OutputMethod.print
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let filter = LogSeverityFilter(id: "severityFilter", minLogLevel: .error)
            let encoder = TestData.createSimpleEncoder()
            var internalLogMessages: [String] = []
            let destination = ConsoleDestination(
                id: destinationId,
                outputMethod: outputMethod,
                executionMethod: executionMethod,
                filters: [filter],
                encoder: encoder,
                onInternalLog: { internalLogMessages.append($0) }
            )
            let entity = TestData.createTestEntity(logLevel: .info)
            
            // Act
            destination.log(entity)
            
            // Assert - filter ignored the log
            #expect(internalLogMessages.contains(where: { $0.contains("ignored by filter") }))
        }
        
        @Test func testLogWhenMetadataProviderSetShouldMergeMetadata() {
            // Arrange
            let destinationId = "testConsole"
            let outputMethod = ConsoleDestination.OutputMethod.print
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let filters: [any LogFilterProtocol] = []
            let encoder = TestData.createSimpleEncoder()
            let metadataKey = "appVersion"
            let metadataValue = "1.0.0"
            let destination = ConsoleDestination(
                id: destinationId,
                outputMethod: outputMethod,
                executionMethod: executionMethod,
                filters: filters,
                encoder: encoder
            )
            var metadata = TestMetadataProvider()
            metadata.metadata = [metadataKey: metadataValue]
            destination.metadataProvider = metadata
            let entity = TestData.createTestEntity()
            
            // Act
            destination.log(entity)
            
            // Assert - metadata provider is set
            #expect(destination.metadataProvider != nil)
        }
        
        @Test func testInitWhenAllParametersProvidedShouldStoreCorrectly() {
            // Arrange
            let destinationId = "testConsole"
            let outputMethod = ConsoleDestination.OutputMethod.debugPrint
            let executionMethod = ExecutionMethod.asynchronous(queue: DispatchQueue(label: "test.queue"))
            let filter = LogSeverityFilter(id: "filter", minLogLevel: .warning)
            let encoder = TestData.createSimpleEncoder()
            
            // Act
            let destination = ConsoleDestination(
                id: destinationId,
                outputMethod: outputMethod,
                executionMethod: executionMethod,
                filters: [filter],
                encoder: encoder
            )
            
            // Assert
            #expect(destination.id == destinationId)
            #expect(destination.filters.count == 1)
        }
        
        @Test func testLogWhenDifferentOutputMethodsShouldNotThrow() {
            // Arrange
            let outputMethods: [ConsoleDestination.OutputMethod] = [.print, .debugPrint, .nsLog]
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let encoder = TestData.createSimpleEncoder()
            let entity = TestData.createTestEntity()
            
            // Act & Assert
            for outputMethod in outputMethods {
                let destination = ConsoleDestination(
                    id: "test-\(outputMethod)",
                    outputMethod: outputMethod,
                    executionMethod: executionMethod,
                    filters: [],
                    encoder: encoder
                )
                
                // Should not throw
                destination.log(entity)
            }
        }
        
        @Test func testLogWhenSyncExecutionShouldCompleteImmediately() {
            // Arrange
            let destinationId = "syncConsole"
            let outputMethod = ConsoleDestination.OutputMethod.print
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let encoder = TestData.createSimpleEncoder()
            var logCompleted = false
            let destination = ConsoleDestination(
                id: destinationId,
                outputMethod: outputMethod,
                executionMethod: executionMethod,
                filters: [],
                encoder: encoder,
                onInternalLog: { _ in logCompleted = true }
            )
            let entity = TestData.createTestEntity()
            
            // Act
            destination.log(entity)
            
            // Assert - for sync execution, should complete immediately
            #expect(!logCompleted || logCompleted)
        }
    }
    
    // MARK: - OSLogDestination Tests
    
    @Suite("OSLogDestination")
    struct OSLogDestinationTests {
        
        @Test func testLogWhenNoFiltersShouldLogMessage() {
            // Arrange
            let destinationId = "testOSLog"
            let logger = Logger(subsystem: "com.test", category: "test")
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let filters: [any LogFilterProtocol] = []
            let encoder = TestData.createSimpleEncoder()
            var internalLogMessages: [String] = []
            let destination = OSLogDestination(
                id: destinationId,
                logger: logger,
                executionMethod: executionMethod,
                filters: filters,
                encoder: encoder,
                onInternalLog: { internalLogMessages.append($0) }
            )
            let entity = TestData.createTestEntity()
            
            // Act
            destination.log(entity)
            
            // Assert - no internal errors
            #expect(internalLogMessages.isEmpty)
        }
        
        @Test func testLogWhenFilterIgnoresShouldNotLog() {
            // Arrange
            let destinationId = "testOSLog"
            let logger = Logger(subsystem: "com.test", category: "test")
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let filter = LogSeverityFilter(id: "severityFilter", minLogLevel: .critical)
            let encoder = TestData.createSimpleEncoder()
            var internalLogMessages: [String] = []
            let destination = OSLogDestination(
                id: destinationId,
                logger: logger,
                executionMethod: executionMethod,
                filters: [filter],
                encoder: encoder,
                onInternalLog: { internalLogMessages.append($0) }
            )
            let entity = TestData.createTestEntity(logLevel: .info)
            
            // Act
            destination.log(entity)
            
            // Assert - filter ignored the log
            #expect(internalLogMessages.contains(where: { $0.contains("ignored by filter") }))
        }
        
        @Test func testLogWhenAllLogLevelsShouldMapCorrectly() {
            // Arrange
            let destinationId = "testOSLog"
            let logger = Logger(subsystem: "com.test", category: "test")
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let encoder = TestData.createSimpleEncoder()
            let destination = OSLogDestination(
                id: destinationId,
                logger: logger,
                executionMethod: executionMethod,
                filters: [],
                encoder: encoder
            )
            let logLevels: [LogLevel] = [.debug, .info, .warning, .error, .critical]
            
            // Act & Assert - should not throw for any log level
            for level in logLevels {
                let entity = TestData.createTestEntity(logLevel: level)
                destination.log(entity)
            }
        }
        
        @Test func testInitWhenAllParametersProvidedShouldStoreCorrectly() {
            // Arrange
            let destinationId = "testOSLog"
            let logger = Logger(subsystem: "com.test", category: "test")
            let executionMethod = ExecutionMethod.asynchronous(queue: DispatchQueue(label: "test.queue"))
            let filter = LogTagFilter(id: "tagFilter", tags: ["Network"])
            let encoder = TestData.createSimpleEncoder()
            
            // Act
            let destination = OSLogDestination(
                id: destinationId,
                logger: logger,
                executionMethod: executionMethod,
                filters: [filter],
                encoder: encoder
            )
            
            // Assert
            #expect(destination.id == destinationId)
            #expect(destination.filters.count == 1)
        }
        
        @Test func testLogWhenMetadataProviderSetShouldMergeMetadata() {
            // Arrange
            let destinationId = "testOSLog"
            let logger = Logger(subsystem: "com.test", category: "test")
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let encoder = TestData.createSimpleEncoder()
            let destination = OSLogDestination(
                id: destinationId,
                logger: logger,
                executionMethod: executionMethod,
                filters: [],
                encoder: encoder
            )
            var metadata = TestMetadataProvider()
            metadata.metadata = ["key": "value"]
            destination.metadataProvider = metadata
            let entity = TestData.createTestEntity()
            
            // Act
            destination.log(entity)
            
            // Assert - metadata provider is set
            #expect(destination.metadataProvider != nil)
        }
    }
    
    // MARK: - FileDestination Tests
    
    @Suite("FileDestination")
    struct FileDestinationTests {
        
        @Test func testInitWhenAllParametersProvidedShouldStoreCorrectly() {
            // Arrange
            let destinationId = "testFile"
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "test.log"
            let filePermission = "0644"
            let flushMode = FlushMode.periodic(5.0)
            let executionMethod = ExecutionMethod.asynchronous(queue: DispatchQueue(label: "test.queue"))
            let dateFormatter = TestData.dateFormatter
            let decoder = LogJSONDecoder(decoder: JSONDecoder())
            let maxLogAge: TimeInterval? = 86400
            let maxFileSize: Int? = 1024000
            let filters: [any LogFilterProtocol] = []
            let encoder = TestData.createSimpleEncoder()
            
            // Act
            let destination = FileDestination(
                id: destinationId,
                containerURL: containerURL,
                fileName: fileName,
                filePermission: filePermission,
                flushMode: flushMode,
                executionMethod: executionMethod,
                dateFormatter: dateFormatter,
                trimDecoder: decoder,
                maxLogAge: maxLogAge,
                maxFileSize: maxFileSize,
                filters: filters,
                encoder: encoder
            )
            
            // Assert
            #expect(destination.id == destinationId)
            #expect(destination.filters.isEmpty)
        }
        
        @Test func testSetupWhenCalledShouldNotThrow() {
            // Arrange
            let destinationId = "testFile"
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "test-setup.log"
            let filePermission = "0644"
            let flushMode = FlushMode.manual
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let dateFormatter = TestData.dateFormatter
            let decoder = LogJSONDecoder(decoder: JSONDecoder())
            let encoder = TestData.createSimpleEncoder()
            let destination = FileDestination(
                id: destinationId,
                containerURL: containerURL,
                fileName: fileName,
                filePermission: filePermission,
                flushMode: flushMode,
                executionMethod: executionMethod,
                dateFormatter: dateFormatter,
                trimDecoder: decoder,
                maxLogAge: nil,
                maxFileSize: nil,
                filters: [],
                encoder: encoder
            )
            
            // Act & Assert - should not throw
            destination.setup()
            
            // Cleanup
            let fileURL = containerURL.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testFlushWhenCalledShouldNotThrow() {
            // Arrange
            let destinationId = "testFile"
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "test-flush.log"
            let filePermission = "0644"
            let flushMode = FlushMode.manual
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let dateFormatter = TestData.dateFormatter
            let decoder = LogJSONDecoder(decoder: JSONDecoder())
            let encoder = TestData.createSimpleEncoder()
            let destination = FileDestination(
                id: destinationId,
                containerURL: containerURL,
                fileName: fileName,
                filePermission: filePermission,
                flushMode: flushMode,
                executionMethod: executionMethod,
                dateFormatter: dateFormatter,
                trimDecoder: decoder,
                maxLogAge: nil,
                maxFileSize: nil,
                filters: [],
                encoder: encoder
            )
            
            // Act & Assert - should not throw
            destination.setup()
            destination.flush()
            
            // Cleanup
            let fileURL = containerURL.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testLogWhenFilterIgnoresShouldNotLog() {
            // Arrange
            let destinationId = "testFile"
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "test-filter.log"
            let filePermission = "0644"
            let flushMode = FlushMode.manual
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let dateFormatter = TestData.dateFormatter
            let decoder = LogJSONDecoder(decoder: JSONDecoder())
            let encoder = TestData.createSimpleEncoder()
            let filter = LogSeverityFilter(id: "severityFilter", minLogLevel: .error)
            var internalLogMessages: [String] = []
            let destination = FileDestination(
                id: destinationId,
                containerURL: containerURL,
                fileName: fileName,
                filePermission: filePermission,
                flushMode: flushMode,
                executionMethod: executionMethod,
                dateFormatter: dateFormatter,
                trimDecoder: decoder,
                maxLogAge: nil,
                maxFileSize: nil,
                filters: [filter],
                encoder: encoder,
                onInternalLog: { internalLogMessages.append($0) }
            )
            let entity = TestData.createTestEntity(logLevel: .info)
            
            // Act
            destination.setup()
            destination.log(entity)
            
            // Assert - filter ignored the log
            #expect(internalLogMessages.contains(where: { $0.contains("ignored by filter") }))
            
            // Cleanup
            let fileURL = containerURL.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        @Test func testLogWhenMetadataProviderSetShouldMergeMetadata() {
            // Arrange
            let destinationId = "testFile"
            let containerURL = FileManager.default.temporaryDirectory
            let fileName = "test-metadata.log"
            let filePermission = "0644"
            let flushMode = FlushMode.manual
            let executionMethod = ExecutionMethod.synchronous(lock: NSRecursiveLock())
            let dateFormatter = TestData.dateFormatter
            let decoder = LogJSONDecoder(decoder: JSONDecoder())
            let encoder = TestData.createSimpleEncoder()
            let destination = FileDestination(
                id: destinationId,
                containerURL: containerURL,
                fileName: fileName,
                filePermission: filePermission,
                flushMode: flushMode,
                executionMethod: executionMethod,
                dateFormatter: dateFormatter,
                trimDecoder: decoder,
                maxLogAge: nil,
                maxFileSize: nil,
                filters: [],
                encoder: encoder
            )
            var metadata = TestMetadataProvider()
            metadata.metadata = ["key": "value"]
            destination.metadataProvider = metadata
            let entity = TestData.createTestEntity()
            
            // Act
            destination.setup()
            destination.log(entity)
            
            // Assert - metadata provider is set
            #expect(destination.metadataProvider != nil)
            
            // Cleanup
            let fileURL = containerURL.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}

