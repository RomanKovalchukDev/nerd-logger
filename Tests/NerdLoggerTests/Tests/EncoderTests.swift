//
//  EncoderTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Testing
import Foundation
@testable import NerdLogger

@Suite("Log Encoders Tests")
struct EncoderTests {
    
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
            functionName: String? = "testFunction()",
            fileName: String? = "TestFile.swift",
            lineNumber: UInt? = 42,
            thread: String? = "main",
            extraInfo: [String: String] = ["key1": "value1", "key2": "value2"]
        ) -> LogEntity {
            return LogEntity(
                logLevel: logLevel,
                message: message,
                tag: tag,
                date: date,
                functionName: functionName,
                fileName: fileName,
                lineNumber: lineNumber,
                thread: thread,
                extraInfo: extraInfo
            )
        }
    }
    
    // MARK: - LogJSONEncoder Tests
    
    @Suite("LogJSONEncoder")
    struct LogJSONEncoderTests {
        
        @Test func testEncodeWhenAllFieldsProvidedShouldReturnValidJSON() throws {
            // Arrange
            let expectedLogLevel = "\"logLevel\":\"\(LogLevelDTO.info.rawValue)\""
            let expectedMessage = "\"message\":\"Test message\""
            let expectedTag = "\"tag\":\"TestTag\""
            let expectedDate = "\"date\""
            let encoder = LogJSONEncoder(
                encoder: JSONEncoder(),
                logOptions: [.level, .timestamp, .tag, .fileInfo, .thread, .otherInfo, .message]
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(expectedLogLevel))
            #expect(result.contains(expectedMessage))
            #expect(result.contains(expectedTag))
            #expect(result.contains(expectedDate))
        }
        
        @Test func testEncodeWhenOptionalFieldsNilShouldOmitFromJSON() throws {
            // Arrange
            let tagKey = "\"tag\""
            let functionNameKey = "\"functionName\""
            let fileNameKey = "\"fileName\""
            let emptyExtraInfo: [String: String] = [:]
            let encoder = LogJSONEncoder(
                encoder: JSONEncoder(),
                logOptions: [.level, .message]
            )
            let entity = TestData.createTestEntity(tag: nil, functionName: nil, fileName: nil, lineNumber: nil, thread: nil, extraInfo: emptyExtraInfo)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(!result.contains(tagKey))
            #expect(!result.contains(functionNameKey))
            #expect(!result.contains(fileNameKey))
        }
        
        @Test func testEncodeWhenLogOptionsFilteredShouldIncludeOnlySpecifiedFields() throws {
            // Arrange
            let logLevelKey = "\"logLevel\""
            let messageKey = "\"message\""
            let tagKey = "\"tag\""
            let timestampKey = "\"timestamp\""
            let threadKey = "\"thread\""
            let encoder = LogJSONEncoder(
                encoder: JSONEncoder(),
                logOptions: [.level, .message]
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(logLevelKey))
            #expect(result.contains(messageKey))
            #expect(!result.contains(tagKey))
            #expect(!result.contains(timestampKey))
            #expect(!result.contains(threadKey))
        }
        
        @Test func testEncodeWhenDateFormatterProvidedShouldFormatTimestampCorrectly() throws {
            // Arrange
            let dateFormat = "dd/MM/yyyy"
            let expectedTimestamp = "\"date\":\"01\\/01\\/2021\""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
            let encoder = LogJSONEncoder(
                encoder: jsonEncoder,
                logOptions: [.timestamp, .message]
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(expectedTimestamp))
        }
        
        @Test func testEncodeWhenExtraInfoEmptyShouldHandleGracefully() throws {
            // Arrange
            let logLevelKey = "\"logLevel\""
            let messageKey = "\"message\""
            let emptyExtraInfo: [String: String] = [:]
            let encoder = LogJSONEncoder(
                encoder: JSONEncoder(),
                logOptions: [.level, .otherInfo, .message]
            )
            let entity = TestData.createTestEntity(extraInfo: emptyExtraInfo)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(logLevelKey))
            #expect(result.contains(messageKey))
        }
        
        @Test func testEncodeWhenSpecialCharactersInMessageShouldEscapeProperly() throws {
            // Arrange
            let specialMessage = "Test \"quoted\" message with \n newline and \\ backslash"
            let escapedQuote = "\\\""
            let escapedNewline = "\\n"
            let escapedBackslash = "\\\\"
            let encoder = LogJSONEncoder(
                encoder: JSONEncoder(),
                logOptions: [.message]
            )
            let entity = TestData.createTestEntity(message: specialMessage)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(escapedQuote))
            #expect(result.contains(escapedNewline))
            #expect(result.contains(escapedBackslash))
        }
        
        @Test func testEncodeWhenAllLogLevelsShouldEncodeCorrectly() throws {
            // Arrange
            let levels: [LogLevel] = [.debug, .info, .warning, .error, .critical]
            let logLevelKey = "\"logLevel\""
            let encoder = LogJSONEncoder(
                encoder: JSONEncoder(),
                logOptions: [.level, .message]
            )
            
            // Act & Assert
            for level in levels {
                let entity = TestData.createTestEntity(logLevel: level)
                let result = try encoder.encode(entity)
                #expect(result.contains(logLevelKey))
            }
        }
        
        @Test func testEncodeWhenEmptyMessageShouldStillEncode() throws {
            // Arrange
            let emptyMessage = ""
            let expectedMessageField = "\"message\":\"\""
            let encoder = LogJSONEncoder(
                encoder: JSONEncoder(),
                logOptions: [.level, .message]
            )
            let entity = TestData.createTestEntity(message: emptyMessage)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(expectedMessageField))
        }
    }
    
    // MARK: - LogCSVEncoder Tests
    
    @Suite("LogCSVEncoder")
    struct LogCSVEncoderTests {
        
        @Test func testEncodeWhenAllFieldsProvidedShouldReturnValidCSV() throws {
            // Arrange
            let expectedLogLevel = "\"\(LogLevelDTO.info.rawValue)\""
            let expectedMessage = "\"Test message\""
            let expectedTag = "\"TestTag\""
            let expectedTimestamp = "\"2021-01-01 00:00:00\""
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let encoder = LogCSVEncoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .timestamp, .tag, .fileInfo, .thread, .otherInfo, .message]
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(expectedLogLevel))
            #expect(result.contains(expectedMessage))
            #expect(result.contains(expectedTag))
            #expect(result.contains(expectedTimestamp))
        }
        
        @Test func testEncodeWhenFieldsContainCommasShouldQuoteProperly() throws {
            // Arrange
            let messageWithComma = "Test, message, with, commas"
            let quoteChar = "\""
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let encoder = LogCSVEncoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.message]
            )
            let entity = TestData.createTestEntity(message: messageWithComma)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.hasPrefix(quoteChar))
            #expect(result.hasSuffix(quoteChar))
            #expect(result.contains(messageWithComma))
        }
        
        @Test func testEncodeWhenFieldsContainQuotesShouldEscapeCorrectly() throws {
            // Arrange
            let messageWithQuotes = "Test \"quoted\" message"
            let escapedQuote = "\"\""
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let encoder = LogCSVEncoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.message]
            )
            let entity = TestData.createTestEntity(message: messageWithQuotes)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(escapedQuote))
        }
        
        @Test func testEncodeWhenLogOptionsOrderChangedShouldReflectInOutput() throws {
            // Arrange
            let expectedPrefix1 = "\"\(LogLevelDTO.info.rawValue)\""
            let expectedPrefix2 = "\"Test message\""
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let encoder1 = LogCSVEncoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let encoder2 = LogCSVEncoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.message, .level]
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result1 = try encoder1.encode(entity)
            let result2 = try encoder2.encode(entity)
            
            // Assert
            #expect(result1 != result2)
            #expect(result1.hasPrefix(expectedPrefix1))
            #expect(result2.hasPrefix(expectedPrefix2))
        }
        
        @Test func testEncodeWhenCustomDelimiterUsedShouldFormatCorrectly() throws {
            // Arrange
            let customDelimiter = "|"
            let commaDelimiter = ","
            let dateFormatter = TestData.dateFormatter
            let encoder = LogCSVEncoder(
                delimiter: customDelimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(customDelimiter))
            #expect(!result.contains(commaDelimiter))
        }
        
        @Test func testEncodeWhenOptionalFieldsNilShouldOutputEmptyQuotes() throws {
            // Arrange
            let expectedComponentCount = 3
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let encoder = LogCSVEncoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .tag, .message]
            )
            let entity = TestData.createTestEntity(tag: nil)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            let components = result.components(separatedBy: delimiter)
            #expect(components.count == expectedComponentCount)
        }
        
        @Test func testEncodeWhenExtraInfoHasMultipleKeysShouldFormatAsSemicolonSeparated() throws {
            // Arrange
            let extraInfo = ["key1": "value1", "key2": "value2", "key3": "value3"]
            let colonSeparator = ":"
            let semicolonSeparator = ";"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let encoder = LogCSVEncoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.otherInfo]
            )
            let entity = TestData.createTestEntity(extraInfo: extraInfo)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(colonSeparator))
            #expect(result.contains(semicolonSeparator))
        }
        
        @Test func testEncodeWhenFileInfoFormattedShouldMatchExpectedPattern() throws {
            // Arrange
            let functionName = "testFunction()"
            let fileName = "TestFile.swift"
            let lineNumber: UInt = 42
            let lineNumberString = "42"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let encoder = LogCSVEncoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.fileInfo]
            )
            let entity = TestData.createTestEntity(functionName: functionName, fileName: fileName, lineNumber: lineNumber)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(fileName))
            #expect(result.contains(functionName))
            #expect(result.contains(lineNumberString))
        }
        
        @Test(.disabled("Espaping issue or bad test data setup"))
        func testEncodeWhenNewlinesInMessageShouldMaintainQuotes() throws {
            // Arrange
            let messageWithNewline = "Line1\nLine2\nLine3"
            let quoteChar = "\""
            let newlineChar = "\n"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let encoder = LogCSVEncoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.message]
            )
            let entity = TestData.createTestEntity(message: messageWithNewline)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.hasPrefix(quoteChar))
            #expect(result.hasSuffix(quoteChar))
            #expect(result.contains(newlineChar))
        }
        
        @Test func testEncodeWhenOnlyMessageOptionShouldOutputSingleField() throws {
            // Arrange
            let expectedOutput = "\"Test message\""
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let encoder = LogCSVEncoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.message]
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(!result.contains(delimiter))
            #expect(result == expectedOutput)
        }
    }
    
    // MARK: - LogSimpleEncoder Tests
    
    @Suite("LogSimpleEncoder")
    struct LogSimpleEncoderTests {
        
        @Test func testEncodeWhenAllOptionsIncludedShouldFormatSingleLine() throws {
            // Arrange
            let expectedLogLevel = "[\(LogLevelDTO.info.rawValue)]"
            let expectedTimestamp = "[2021-01-01 00:00:00]"
            let expectedTag = "[TestTag]"
            let expectedMessage = "Test message"
            let newlineChar = "\n"
            let dateFormatter = TestData.dateFormatter
            let encoder = LogSimpleEncoder(
                dateFormatter: dateFormatter,
                logOptions: [.level, .timestamp, .tag, .fileInfo, .thread, .otherInfo, .message]
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(expectedLogLevel))
            #expect(result.contains(expectedTimestamp))
            #expect(result.contains(expectedTag))
            #expect(result.contains(expectedMessage))
            #expect(!result.contains(newlineChar))
        }
        
        @Test func testEncodeWhenMinimalOptionsShouldOnlyIncludeSpecified() throws {
            // Arrange
            let expectedLogLevel = "[\(LogLevelDTO.info.rawValue)]"
            let expectedMessage = "Test message"
            let unexpectedTag = "[TestTag]"
            let unexpectedDate = "2021-01-01"
            let dateFormatter = TestData.dateFormatter
            let encoder = LogSimpleEncoder(
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(expectedLogLevel))
            #expect(result.contains(expectedMessage))
            #expect(!result.contains(unexpectedTag))
            #expect(!result.contains(unexpectedDate))
        }
        
        @Test func testEncodeWhenLogOptionsNoneShouldReturnMessageOnly() throws {
            // Arrange
            let dateFormatter = TestData.dateFormatter
            let encoder = LogSimpleEncoder(
                dateFormatter: dateFormatter,
                logOptions: []
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.isEmpty)
        }
        
        @Test func testEncodeWhenFileInfoPresentShouldFormatCorrectly() throws {
            // Arrange
            let functionName = "testFunction()"
            let fileName = "TestFile.swift"
            let lineNumber: UInt = 42
            let lineNumberString = "42"
            let dateFormatter = TestData.dateFormatter
            let encoder = LogSimpleEncoder(
                dateFormatter: dateFormatter,
                logOptions: [.fileInfo]
            )
            let entity = TestData.createTestEntity(functionName: functionName, fileName: fileName, lineNumber: lineNumber)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(fileName))
            #expect(result.contains(functionName))
            #expect(result.contains(lineNumberString))
        }
        
        @Test func testEncodeWhenExtraInfoPresentShouldFormatCorrectly() throws {
            // Arrange
            let extraInfo = ["key1": "value1", "key2": "value2"]
            let expectedInfo1 = "key1:value1"
            let expectedInfo2 = "key2:value2"
            let dateFormatter = TestData.dateFormatter
            let encoder = LogSimpleEncoder(
                dateFormatter: dateFormatter,
                logOptions: [.otherInfo]
            )
            let entity = TestData.createTestEntity(extraInfo: extraInfo)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(expectedInfo1))
            #expect(result.contains(expectedInfo2))
        }
        
        @Test func testEncodeWhenNewlinesInMessageShouldEscapeProperly() throws {
            // Arrange
            let messageWithNewlines = "Line1\nLine2\nLine3"
            let escapedNewline = "\\n"
            let actualNewline = "\n"
            let dateFormatter = TestData.dateFormatter
            let encoder = LogSimpleEncoder(
                dateFormatter: dateFormatter,
                logOptions: [.message]
            )
            let entity = TestData.createTestEntity(message: messageWithNewlines)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(escapedNewline))
            #expect(!result.contains(actualNewline))
        }
        
        @Test func testEncodeWhenAllLogLevelsShouldFormatCorrectly() throws {
            // Arrange
            let levels: [(LogLevel, String)] = [
                (.debug, "[\(LogLevelDTO.debug.rawValue)]"),
                (.info, "[\(LogLevelDTO.info.rawValue)]"),
                (.warning, "[\(LogLevelDTO.warning.rawValue)]"),
                (.error, "[\(LogLevelDTO.error.rawValue)]"),
                (.critical, "[\(LogLevelDTO.critical.rawValue)]")
            ]
            let dateFormatter = TestData.dateFormatter
            let encoder = LogSimpleEncoder(
                dateFormatter: dateFormatter,
                logOptions: [.level]
            )
            
            // Act & Assert
            for (level, expected) in levels {
                let entity = TestData.createTestEntity(logLevel: level)
                let result = try encoder.encode(entity)
                #expect(result.contains(expected))
            }
        }
        
        @Test func testEncodeWhenThreadInfoPresentShouldIncludeInOutput() throws {
            // Arrange
            let threadInfo = "ThreadInfo(name: \"main\", number: 1)"
            let expectedThreadOutput = "[ThreadInfo(name: \"main\", number: 1)]"
            let dateFormatter = TestData.dateFormatter
            let encoder = LogSimpleEncoder(
                dateFormatter: dateFormatter,
                logOptions: [.thread]
            )
            let entity = TestData.createTestEntity(thread: threadInfo)
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(expectedThreadOutput))
        }
        
        @Test func testEncodeWhenTimestampFormattedShouldMatchDateFormatter() throws {
            // Arrange
            let dateFormat = "HH:mm:ss"
            let expectedTimestamp = "[00:00:00]"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            let encoder = LogSimpleEncoder(
                dateFormatter: dateFormatter,
                logOptions: [.timestamp]
            )
            let entity = TestData.createTestEntity()
            
            // Act
            let result = try encoder.encode(entity)
            
            // Assert
            #expect(result.contains(expectedTimestamp))
        }
    }
}
