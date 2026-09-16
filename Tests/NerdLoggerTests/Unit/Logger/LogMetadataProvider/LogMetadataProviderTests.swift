//
//  LogMetadataProviderTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Testing
import Foundation
@testable import NerdLogger

@Suite("Log Metadata Provider Tests")
struct LogMetadataProviderTests {
    
    @Suite("LogMetadataProvider")
    struct LogMetadataProviderBasicTests {
        
        @Test func testMetadataWhenSetShouldStoreCorrectly() {
            // Arrange
            let key = "appVersion"
            let value = "1.0.0"
            var provider = TestMetadataProvider()
            
            // Act
            provider.metadata[key] = value
            
            // Assert
            #expect(provider.metadata[key] == value)
        }
        
        @Test func testMetadataWhenEmptyShouldReturnEmpty() {
            // Arrange
            let provider = TestMetadataProvider()
            let expectedCount = 0
            
            // Act
            let metadata = provider.metadata
            
            // Assert
            #expect(metadata.count == expectedCount)
        }
        
        @Test func testMetadataWhenMultipleKeysShouldStoreAll() {
            // Arrange
            let key1 = "appVersion"
            let value1 = "1.0.0"
            let key2 = "platform"
            let value2 = "iOS"
            let key3 = "build"
            let value3 = "123"
            let expectedCount = 3
            var provider = TestMetadataProvider()
            
            // Act
            provider.metadata = [key1: value1, key2: value2, key3: value3]
            
            // Assert
            #expect(provider.metadata.count == expectedCount)
            #expect(provider.metadata[key1] == value1)
            #expect(provider.metadata[key2] == value2)
            #expect(provider.metadata[key3] == value3)
        }
        
        @Test func testMetadataWhenUpdatedShouldReplaceValue() {
            // Arrange
            let key = "version"
            let initialValue = "1.0.0"
            let updatedValue = "2.0.0"
            var provider = TestMetadataProvider()
            provider.metadata[key] = initialValue
            
            // Act
            provider.metadata[key] = updatedValue
            
            // Assert
            #expect(provider.metadata[key] == updatedValue)
        }
        
        @Test func testMetadataWhenRemovedShouldDeleteKey() {
            // Arrange
            let key = "tempKey"
            let value = "tempValue"
            let expectedCount = 0
            var provider = TestMetadataProvider()
            provider.metadata[key] = value
            
            // Act
            provider.metadata.removeValue(forKey: key)
            
            // Assert
            #expect(provider.metadata[key] == nil)
            #expect(provider.metadata.count == expectedCount)
        }
        
        @Test func testMetadataWhenClearedShouldBeEmpty() {
            // Arrange
            let expectedCount = 0
            var provider = TestMetadataProvider()
            provider.metadata = ["key1": "value1", "key2": "value2", "key3": "value3"]
            
            // Act
            provider.metadata.removeAll()
            
            // Assert
            #expect(provider.metadata.count == expectedCount)
        }
        
        @Test func testMetadataWhenSpecialCharactersShouldStoreCorrectly() {
            // Arrange
            let key = "special!@#$%^&*()"
            let value = "value with spaces and 特殊字符"
            var provider = TestMetadataProvider()
            
            // Act
            provider.metadata[key] = value
            
            // Assert
            #expect(provider.metadata[key] == value)
        }
        
        @Test func testMetadataWhenEmptyStringsShouldStoreCorrectly() {
            // Arrange
            let key = ""
            let value = ""
            var provider = TestMetadataProvider()
            
            // Act
            provider.metadata[key] = value
            
            // Assert
            #expect(provider.metadata[key] == value)
        }
        
        @Test func testMetadataWhenLongStringsShouldStoreCorrectly() {
            // Arrange
            let key = String(repeating: "k", count: 1000)
            let value = String(repeating: "v", count: 1000)
            var provider = TestMetadataProvider()
            
            // Act
            provider.metadata[key] = value
            
            // Assert
            #expect(provider.metadata[key] == value)
        }
        
        @Test func testMetadataWhenMergedWithEntityInfoShouldCombineCorrectly() {
            // Arrange
            let metadataKey = "appVersion"
            let metadataValue = "1.0.0"
            let entityKey = "requestId"
            let entityValue = "12345"
            var provider = TestMetadataProvider()
            provider.metadata = [metadataKey: metadataValue]
            var entityInfo = [entityKey: entityValue]
            let expectedCount = 2
            
            // Act
            entityInfo.merge(provider.metadata) { entityValue, _ in entityValue }
            
            // Assert
            #expect(entityInfo.count == expectedCount)
            #expect(entityInfo[metadataKey] == metadataValue)
            #expect(entityInfo[entityKey] == entityValue)
        }
        
        @Test func testMetadataWhenMergedWithConflictShouldPreferEntityValue() {
            // Arrange
            let conflictKey = "userId"
            let metadataValue = "metadata-user"
            let entityValue = "entity-user"
            var provider = TestMetadataProvider()
            provider.metadata = [conflictKey: metadataValue]
            var entityInfo = [conflictKey: entityValue]
            
            // Act
            entityInfo.merge(provider.metadata) { entityValue, _ in entityValue }
            
            // Assert
            #expect(entityInfo[conflictKey] == entityValue)
        }
    }
}

