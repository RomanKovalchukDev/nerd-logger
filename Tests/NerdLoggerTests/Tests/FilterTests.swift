//
//  FilterTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Testing
import Foundation
@testable import NerdLogger

@Suite("Log Filters Tests")
struct FilterTests {
    
    // MARK: - Test Data
    
    private enum TestData {
        static func createTestEntity(
            logLevel: LogLevel = .info,
            message: String = "Test message",
            tag: String? = "TestTag"
        ) -> LogEntity {
            return LogEntity(
                logLevel: logLevel,
                message: message,
                tag: tag,
                date: Date(),
                functionName: "testFunction()",
                fileName: "TestFile.swift",
                lineNumber: 42,
                thread: "main",
                extraInfo: [:]
            )
        }
    }
    
    // MARK: - LogSeverityFilter Tests
    
    @Suite("LogSeverityFilter")
    struct LogSeverityFilterTests {
        
        @Test func testShouldIgnoreLogWhenBelowMinimumShouldReturnTrue() {
            // Arrange
            let filter = LogSeverityFilter(id: "testFilter", minLogLevel: .warning)
            let entity = TestData.createTestEntity(logLevel: .info)
            
            // Act
            let result = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(result == true)
        }
        
        @Test func testShouldIgnoreLogWhenAtMinimumShouldReturnFalse() {
            // Arrange
            let filter = LogSeverityFilter(id: "testFilter", minLogLevel: .warning)
            let entity = TestData.createTestEntity(logLevel: .warning)
            
            // Act
            let result = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(result == false)
        }
        
        @Test func testShouldIgnoreLogWhenAboveMinimumShouldReturnFalse() {
            // Arrange
            let filter = LogSeverityFilter(id: "testFilter", minLogLevel: .warning)
            let entity = TestData.createTestEntity(logLevel: .error)
            
            // Act
            let result = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(result == false)
        }
        
        @Test func testShouldIgnoreLogWhenAllLevelsTestedShouldFilterCorrectly() {
            // Arrange
            let filter = LogSeverityFilter(id: "testFilter", minLogLevel: .warning)
            let debugEntity = TestData.createTestEntity(logLevel: .debug)
            let infoEntity = TestData.createTestEntity(logLevel: .info)
            let warningEntity = TestData.createTestEntity(logLevel: .warning)
            let errorEntity = TestData.createTestEntity(logLevel: .error)
            let criticalEntity = TestData.createTestEntity(logLevel: .critical)
            
            // Act & Assert
            #expect(filter.shouldIgnoreLog(debugEntity) == true)
            #expect(filter.shouldIgnoreLog(infoEntity) == true)
            #expect(filter.shouldIgnoreLog(warningEntity) == false)
            #expect(filter.shouldIgnoreLog(errorEntity) == false)
            #expect(filter.shouldIgnoreLog(criticalEntity) == false)
        }
        
        @Test func testShouldIgnoreLogWhenMinLevelDebugShouldAllowAll() {
            // Arrange
            let filter = LogSeverityFilter(id: "testFilter", minLogLevel: .debug)
            let debugEntity = TestData.createTestEntity(logLevel: .debug)
            let infoEntity = TestData.createTestEntity(logLevel: .info)
            let criticalEntity = TestData.createTestEntity(logLevel: .critical)
            
            // Act & Assert
            #expect(filter.shouldIgnoreLog(debugEntity) == false)
            #expect(filter.shouldIgnoreLog(infoEntity) == false)
            #expect(filter.shouldIgnoreLog(criticalEntity) == false)
        }
        
        @Test func testShouldIgnoreLogWhenMinLevelCriticalShouldOnlyAllowCritical() {
            // Arrange
            let filter = LogSeverityFilter(id: "testFilter", minLogLevel: .critical)
            let debugEntity = TestData.createTestEntity(logLevel: .debug)
            let infoEntity = TestData.createTestEntity(logLevel: .info)
            let warningEntity = TestData.createTestEntity(logLevel: .warning)
            let errorEntity = TestData.createTestEntity(logLevel: .error)
            let criticalEntity = TestData.createTestEntity(logLevel: .critical)
            
            // Act & Assert
            #expect(filter.shouldIgnoreLog(debugEntity) == true)
            #expect(filter.shouldIgnoreLog(infoEntity) == true)
            #expect(filter.shouldIgnoreLog(warningEntity) == true)
            #expect(filter.shouldIgnoreLog(errorEntity) == true)
            #expect(filter.shouldIgnoreLog(criticalEntity) == false)
        }
        
        @Test func testTypeNameShouldReturnCorrectIdentifier() {
            // Arrange
            let filter = LogSeverityFilter(id: "testFilter", minLogLevel: .info)
            
            // Act
            let typeName = filter.typeName
            
            // Assert
            #expect(typeName == "LogSeverityFilter")
        }
    }
    
    // MARK: - LogTagFilter Tests
    
    @Suite("LogTagFilter")
    struct LogTagFilterTests {
        
        @Test func testShouldIgnoreLogWhenTagMatchesAllowedShouldReturnFalse() {
            // Arrange
            let allowedTags = ["Network", "Database", "UI"]
            let filter = LogTagFilter(id: "testFilter", tags: allowedTags)
            let entity = TestData.createTestEntity(tag: "Network")
            
            // Act
            let result = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(result == false)
        }
        
        @Test func testShouldIgnoreLogWhenTagNotInAllowedShouldReturnTrue() {
            // Arrange
            let allowedTags = ["Network", "Database", "UI"]
            let filter = LogTagFilter(id: "testFilter", tags: allowedTags)
            let entity = TestData.createTestEntity(tag: "Analytics")
            
            // Act
            let result = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(result == true)
        }
        
        @Test func testShouldIgnoreLogWhenEntityTagNilShouldReturnTrue() {
            // Arrange
            let allowedTags = ["Network", "Database"]
            let filter = LogTagFilter(id: "testFilter", tags: allowedTags)
            let entity = TestData.createTestEntity(tag: nil)
            
            // Act
            let result = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(result == true)
        }
        
        @Test func testShouldIgnoreLogWhenAllowedTagsEmptyShouldReturnTrue() {
            // Arrange
            let filter = LogTagFilter(id: "testFilter", tags: [])
            let entity = TestData.createTestEntity(tag: "Network")
            
            // Act
            let result = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(result == true)
        }
        
        @Test func testShouldIgnoreLogWhenCaseSensitiveMatchShouldWorkCorrectly() {
            // Arrange
            let allowedTags = ["Network", "database", "UI"]
            let filter = LogTagFilter(id: "testFilter", tags: allowedTags)
            let networkEntity = TestData.createTestEntity(tag: "Network")
            let networkLowerEntity = TestData.createTestEntity(tag: "network")
            let databaseEntity = TestData.createTestEntity(tag: "database")
            let databaseUpperEntity = TestData.createTestEntity(tag: "Database")
            
            // Act & Assert
            #expect(filter.shouldIgnoreLog(networkEntity) == false)
            #expect(filter.shouldIgnoreLog(networkLowerEntity) == true)
            #expect(filter.shouldIgnoreLog(databaseEntity) == false)
            #expect(filter.shouldIgnoreLog(databaseUpperEntity) == true)
        }
        
        @Test func testShouldIgnoreLogWhenMultipleAllowedTagsShouldMatchAny() {
            // Arrange
            let allowedTags = ["Tag1", "Tag2", "Tag3", "Tag4", "Tag5"]
            let filter = LogTagFilter(id: "testFilter", tags: allowedTags)
            
            // Act & Assert
            #expect(filter.shouldIgnoreLog(TestData.createTestEntity(tag: "Tag1")) == false)
            #expect(filter.shouldIgnoreLog(TestData.createTestEntity(tag: "Tag3")) == false)
            #expect(filter.shouldIgnoreLog(TestData.createTestEntity(tag: "Tag5")) == false)
            #expect(filter.shouldIgnoreLog(TestData.createTestEntity(tag: "TagX")) == true)
        }
        
        @Test func testInitWhenAllowedTagsProvidedShouldStoreValue() {
            // Arrange
            let allowedTags = ["Tag1", "Tag2", "Tag3"]
            
            // Act
            let filter = LogTagFilter(id: "testFilter", tags: allowedTags)
            
            // Assert
            #expect(filter.tags == allowedTags)
        }
        
        @Test func testTypeNameShouldReturnCorrectIdentifier() {
            // Arrange
            let filter = LogTagFilter(id: "testFilter", tags: ["Test"])
            
            // Act
            let typeName = filter.typeName
            
            // Assert
            #expect(typeName == "LogTagFilter")
        }
    }
    
    // MARK: - LogClosureFilter Tests
    
    @Suite("LogClosureFilter")
    struct LogClosureFilterTests {
        
        @Test func testShouldIgnoreLogWhenClosureReturnsTrueShouldReturnTrue() {
            // Arrange
            let filter = LogClosureFilter(id: "testFilter") { _ in true }
            let entity = TestData.createTestEntity()
            
            // Act
            let result = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(result == true)
        }
        
        @Test func testShouldIgnoreLogWhenClosureReturnsFalseShouldReturnFalse() {
            // Arrange
            let filter = LogClosureFilter(id: "testFilter") { _ in false }
            let entity = TestData.createTestEntity()
            
            // Act
            let result = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(result == false)
        }
        
        @Test func testShouldIgnoreLogWhenComplexLogicInClosureShouldEvaluateCorrectly() {
            // Arrange
            let filter = LogClosureFilter(id: "testFilter") { entity in
                if entity.logLevel.rawValue < LogLevel.warning.rawValue {
                    return true
                }
                if let tag = entity.tag, tag == "IgnoreMe" {
                    return true
                }
                return false
            }
            
            let debugEntity = TestData.createTestEntity(logLevel: .debug, tag: "Network")
            let infoEntity = TestData.createTestEntity(logLevel: .info, tag: "Database")
            let warningEntity = TestData.createTestEntity(logLevel: .warning, tag: "Network")
            let errorWithIgnoreTag = TestData.createTestEntity(logLevel: .error, tag: "IgnoreMe")
            
            // Act & Assert
            #expect(filter.shouldIgnoreLog(debugEntity) == true)
            #expect(filter.shouldIgnoreLog(infoEntity) == true)
            #expect(filter.shouldIgnoreLog(warningEntity) == false)
            #expect(filter.shouldIgnoreLog(errorWithIgnoreTag) == true)
        }
        
        @Test func testShouldIgnoreLogWhenClosureChecksMessageContentShouldWorkCorrectly() {
            // Arrange
            let filter = LogClosureFilter(id: "testFilter") { entity in
                entity.message.contains("SKIP")
            }
            
            let normalEntity = TestData.createTestEntity(message: "Normal message")
            let skipEntity = TestData.createTestEntity(message: "SKIP this message")
            
            // Act & Assert
            #expect(filter.shouldIgnoreLog(normalEntity) == false)
            #expect(filter.shouldIgnoreLog(skipEntity) == true)
        }
        
        @Test func testShouldIgnoreLogWhenClosureChecksMultipleConditionsShouldEvaluate() {
            // Arrange
            let filter = LogClosureFilter(id: "testFilter") { entity in
                guard entity.logLevel == .debug else {
                    return false
                }
                guard let tag = entity.tag, tag.hasPrefix("Test") else {
                    return false
                }
                return true
            }
            
            let debugTestEntity = TestData.createTestEntity(logLevel: .debug, tag: "TestModule")
            let debugOtherEntity = TestData.createTestEntity(logLevel: .debug, tag: "OtherModule")
            let infoTestEntity = TestData.createTestEntity(logLevel: .info, tag: "TestModule")
            
            // Act & Assert
            #expect(filter.shouldIgnoreLog(debugTestEntity) == true)
            #expect(filter.shouldIgnoreLog(debugOtherEntity) == false)
            #expect(filter.shouldIgnoreLog(infoTestEntity) == false)
        }
        
        @Test func testInitWhenClosureProvidedShouldStoreValue() {
            // Arrange
            var closureCalled = false
            let filter = LogClosureFilter(id: "testFilter") { _ in
                closureCalled = true
                return false
            }
            let entity = TestData.createTestEntity()
            
            // Act
            _ = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(closureCalled == true)
        }
        
        @Test func testTypeNameShouldReturnCorrectIdentifier() {
            // Arrange
            let filter = LogClosureFilter(id: "testFilter") { _ in false }
            
            // Act
            let typeName = filter.typeName
            
            // Assert
            #expect(typeName == "LogClosureFilter")
        }
        
        @Test func testShouldIgnoreLogWhenClosureAccessesAllEntityPropertiesShouldNotCrash() {
            // Arrange
            let filter = LogClosureFilter(id: "testFilter") { entity in
                _ = entity.logLevel
                _ = entity.message
                _ = entity.tag
                _ = entity.date
                _ = entity.functionName
                _ = entity.fileName
                _ = entity.lineNumber
                _ = entity.thread
                _ = entity.extraInfo
                return false
            }
            let entity = TestData.createTestEntity()
            
            // Act
            let result = filter.shouldIgnoreLog(entity)
            
            // Assert
            #expect(result == false)
        }
    }
}
