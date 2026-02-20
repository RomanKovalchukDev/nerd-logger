//
//  DecoderTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Testing
import Foundation
@testable import NerdLogger

@Suite("Log Decoders Tests")
struct DecoderTests {
    
    // MARK: - Test Data
    
    private enum TestData {
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone(identifier: "UTC")
            return formatter
        }()
    }
    
    // MARK: - LogJSONDecoder Tests
    
    @Suite("LogJSONDecoder")
    struct LogJSONDecoderTests {
        
        @Test func testDecodeWhenValidJSONShouldReturnLogEntity() throws {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let message = "Test message"
            let tag = "TestTag"
            let timestamp = "2021-01-01 00:00:00"
            let functionName = "testFunction()"
            let fileName = "TestFile.swift"
            let lineNumber = 42
            let thread = "main"
            let extraKey = "key"
            let extraValue = "value"
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            let validJSON = """
            {
                "logLevel": "\(logLevel)",
                "message": "\(message)",
                "tag": "\(tag)",
                "timestamp": "\(timestamp)",
                "functionName": "\(functionName)",
                "fileName": "\(fileName)",
                "lineNumber": \(lineNumber),
                "thread": "\(thread)",
                "extraInfo": {"\(extraKey)": "\(extraValue)"}
            }
            """
            
            // Act
            let result = try decoder.decode(validJSON)
            
            // Assert
            #expect(result != nil)
            #expect(result?.logLevel == .info)
            #expect(result?.message == message)
            #expect(result?.tag == tag)
            #expect(result?.functionName == functionName)
        }
        
        @Test func testDecodeWhenEmptyStringShouldReturnNil() throws {
            // Arrange
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            let emptyString = ""
            
            // Act
            let result = try decoder.decode(emptyString)
            
            // Assert
            #expect(result == nil)
        }
        
        @Test func testDecodeWhenMissingRequiredFieldsShouldThrowError() {
            // Arrange
            let tag = "TestTag"
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            let invalidJSON = """
            {
                "tag": "\(tag)"
            }
            """
            
            // Act & Assert
            #expect(throws: Error.self) {
                _ = try decoder.decode(invalidJSON)
            }
        }
        
        @Test func testDecodeWhenOptionalFieldsMissingShouldSetToNil() throws {
            // Arrange
            let logLevel = LogLevelDTO.debug.rawValue
            let message = "Minimal message"
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            let minimalJSON = """
            {
                "logLevel": "\(logLevel)",
                "message": "\(message)"
            }
            """
            
            // Act
            let result = try decoder.decode(minimalJSON)
            
            // Assert
            #expect(result != nil)
            #expect(result?.logLevel == .debug)
            #expect(result?.message == message)
            #expect(result?.tag == nil)
            #expect(result?.functionName == nil)
        }
        
        @Test func testDecodeWhenInvalidJSONFormatShouldThrowError() {
            // Arrange
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            let invalidJSON = "{ invalid json }"
            
            // Act & Assert
            #expect(throws: Error.self) {
                _ = try decoder.decode(invalidJSON)
            }
        }
        
        @Test func testDecodeWhenInvalidLogLevelShouldThrowError() {
            // Arrange
            let logLevel = "invalid"
            let message = "Test"
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            let invalidLevelJSON = """
            {
                "logLevel": "\(logLevel)",
                "message": "\(message)"
            }
            """
            
            // Act & Assert
            #expect(throws: Error.self) {
                _ = try decoder.decode(invalidLevelJSON)
            }
        }
        
        @Test func testDecodeWhenInvalidDateFormatShouldHandleGracefully() throws {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let message = "Test"
            let timestamp = "invalid-date"
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            let invalidDateJSON = """
            {
                "logLevel": "\(logLevel)",
                "message": "\(message)",
                "timestamp": "\(timestamp)"
            }
            """
            
            // Act
            let result = try decoder.decode(invalidDateJSON)
            
            // Assert
            #expect(result != nil)
            #expect(result?.date == nil)
        }
        
        @Test func testDecodeWhenExtraInfoPresentShouldParseDictionary() throws {
            // Arrange
            let logLevel = LogLevelDTO.error.rawValue
            let message = "Error occurred"
            let errorCode = "500"
            let errorType = "ServerError"
            let userId = "12345"
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            let jsonWithExtraInfo = """
            {
                "logLevel": "\(logLevel)",
                "message": "\(message)",
                "extraInfo": {
                    "errorCode": "\(errorCode)",
                    "errorType": "\(errorType)",
                    "userId": "\(userId)"
                }
            }
            """
            
            // Act
            let result = try decoder.decode(jsonWithExtraInfo)
            
            // Assert
            #expect(result != nil)
            #expect(result?.extraInfo["errorCode"] == errorCode)
            #expect(result?.extraInfo["errorType"] == errorType)
            #expect(result?.extraInfo["userId"] == userId)
        }
        
        @Test func testDecodeWhenAllFieldsProvidedShouldMapCorrectly() throws {
            // Arrange
            let logLevel = LogLevelDTO.warning.rawValue
            let message = "Complete log entry"
            let tag = "MyTag"
            let timestamp = "2021-06-15 12:30:45"
            let functionName = "myFunction()"
            let fileName = "MyFile.swift"
            let lineNumber: UInt = 100
            let thread = "background"
            let infoKey = "info"
            let infoValue = "data"
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            let completeJSON = """
            {
                "logLevel": "\(logLevel)",
                "message": "\(message)",
                "tag": "\(tag)",
                "timestamp": "\(timestamp)",
                "functionName": "\(functionName)",
                "fileName": "\(fileName)",
                "lineNumber": \(lineNumber),
                "thread": "\(thread)",
                "extraInfo": {"\(infoKey)": "\(infoValue)"}
            }
            """
            
            // Act
            let result = try decoder.decode(completeJSON)
            
            // Assert
            #expect(result != nil)
            #expect(result?.logLevel == .warning)
            #expect(result?.message == message)
            #expect(result?.tag == tag)
            #expect(result?.functionName == functionName)
            #expect(result?.fileName == fileName)
            #expect(result?.lineNumber == lineNumber)
            #expect(result?.thread == thread)
            #expect(result?.extraInfo[infoKey] == infoValue)
        }
        
        @Test func testDecodeWhenEscapedCharactersShouldUnescapeProperly() throws {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let message = "Line1\\nLine2\\tTabbed\\r\\nWindows"
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            let escapedJSON = """
            {
                "logLevel": "\(logLevel)",
                "message": "\(message)"
            }
            """
            
            // Act
            let result = try decoder.decode(escapedJSON)
            
            // Assert
            #expect(result != nil)
            #expect(result?.message.contains("\n") ?? false)
            #expect(result?.message.contains("\t") ?? false)
        }
        
        @Test func testDecodeWhenAllLogLevelsShouldDecodeCorrectly() throws {
            // Arrange
            let levels = [LogLevelDTO.debug.rawValue, LogLevelDTO.info.rawValue, LogLevelDTO.warning.rawValue, LogLevelDTO.error.rawValue, LogLevelDTO.critical.rawValue]
            let message = "Test"
            let jsonDecoder = JSONDecoder()
            let decoder = LogJSONDecoder(decoder: jsonDecoder)
            
            // Act & Assert
            for levelString in levels {
                let json = """
                {
                    "logLevel": "\(levelString)",
                    "message": "\(message)"
                }
                """
                let result = try decoder.decode(json)
                #expect(result != nil)
            }
        }
    }
    
    // MARK: - LogCSVDecoder Tests
    
    @Suite("LogCSVDecoder")
    struct LogCSVDecoderTests {
        
        @Test func testDecodeWhenValidCSVShouldReturnLogEntity() throws {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let timestamp = "2021-01-01 00:00:00"
            let tag = "TestTag"
            let fileName = "TestFile.swift"
            let functionName = "testFunction()"
            let lineNumber = 42
            let thread = "main"
            let extraInfo = "key:value"
            let message = "Test message"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .timestamp, .tag, .fileInfo, .thread, .otherInfo, .message]
            )
            let validCSV = "\"\(logLevel)\",\"\(timestamp)\",\"\(tag)\",\"\(fileName) \(functionName):\(lineNumber)\",\"\(thread)\",\"\(extraInfo)\",\"\(message)\""
            
            // Act
            let result = try decoder.decode(validCSV)
            
            // Assert
            #expect(result != nil)
            #expect(result?.logLevel == .info)
            #expect(result?.message == message)
            #expect(result?.tag == tag)
        }
        
        @Test func testDecodeWhenEmptyStringShouldReturnNil() throws {
            // Arrange
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: ",",
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let emptyString = ""
            
            // Act
            let result = try decoder.decode(emptyString)
            
            // Assert
            #expect(result == nil)
        }
        
        @Test func testDecodeWhenQuotedFieldsShouldParseCorrectly() throws {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let message = "Message with, comma"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let quotedCSV = "\"\(logLevel)\",\"\(message)\""
            
            // Act
            let result = try decoder.decode(quotedCSV)
            
            // Assert
            #expect(result != nil)
            #expect(result?.message == message)
        }
        
        @Test func testDecodeWhenEscapedQuotesShouldUnescapeProperly() throws {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let expectedMessage = "Message with \"quotes\""
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let escapedQuotesCSV = "\"\(logLevel)\",\"Message with \"\"quotes\"\"\""
            
            // Act
            let result = try decoder.decode(escapedQuotesCSV)
            
            // Assert
            #expect(result != nil)
            #expect(result?.message == expectedMessage)
        }
        
        @Test func testDecodeWhenLogOptionsOrderChangedShouldParseAccordingly() throws {
            // Arrange
            let message = "Test message"
            let logLevel = LogLevelDTO.warning.rawValue
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.message, .level]
            )
            let reversedCSV = "\"\(message)\",\"\(logLevel)\""
            
            // Act
            let result = try decoder.decode(reversedCSV)
            
            // Assert
            #expect(result != nil)
            #expect(result?.logLevel == .warning)
            #expect(result?.message == message)
        }
        
        @Test func testDecodeWhenCustomDelimiterUsedShouldParseCorrectly() throws {
            // Arrange
            let logLevel = LogLevelDTO.debug.rawValue
            let message = "Debug message"
            let delimiter = "|"
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let pipeSeparatedCSV = "\"\(logLevel)\"\(delimiter)\"\(message)\""
            
            // Act
            let result = try decoder.decode(pipeSeparatedCSV)
            
            // Assert
            #expect(result != nil)
            #expect(result?.logLevel == .debug)
            #expect(result?.message == message)
        }
        
        @Test func testDecodeWhenFewerFieldsThanExpectedShouldHandleGracefully() {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let timestamp = "2021-01-01 00:00:00"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .timestamp, .tag, .message]
            )
            let incompleteCSV = "\"\(logLevel)\",\"\(timestamp)\""
            
            // Act & Assert
            #expect(throws: Error.self) {
                _ = try decoder.decode(incompleteCSV)
            }
        }
        
        @Test func testDecodeWhenMoreFieldsThanExpectedShouldIgnoreExtra() throws {
            // Arrange
            let logLevel = LogLevelDTO.error.rawValue
            let message = "Error message"
            let extra1 = "extra1"
            let extra2 = "extra2"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let extraFieldsCSV = "\"\(logLevel)\",\"\(message)\",\"\(extra1)\",\"\(extra2)\""
            
            // Act
            let result = try decoder.decode(extraFieldsCSV)
            
            // Assert
            #expect(result != nil)
            #expect(result?.logLevel == .error)
            #expect(result?.message == message)
        }
        
        @Test func testDecodeWhenFileInfoFormattedShouldParseCorrectly() throws {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let fileName = "MyFile.swift"
            let functionName = "myFunction()"
            let lineNumber: UInt = 123
            let message = "Message"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .fileInfo, .message]
            )
            let csvWithFileInfo = "\"\(logLevel)\",\"\(fileName) \(functionName):\(lineNumber)\",\"\(message)\""
            
            // Act
            let result = try decoder.decode(csvWithFileInfo)
            
            // Assert
            #expect(result != nil)
            #expect(result?.fileName == fileName)
            #expect(result?.functionName == functionName)
            #expect(result?.lineNumber == lineNumber)
        }
        
        @Test func testDecodeWhenExtraInfoSemicolonSeparatedShouldParseDictionary() throws {
            // Arrange
            let logLevel = LogLevelDTO.critical.rawValue
            let key1 = "key1"
            let value1 = "value1"
            let key2 = "key2"
            let value2 = "value2"
            let key3 = "key3"
            let value3 = "value3"
            let message = "Critical error"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .otherInfo, .message]
            )
            let csvWithExtraInfo = "\"\(logLevel)\",\"\(key1):\(value1);\(key2):\(value2);\(key3):\(value3)\",\"\(message)\""
            
            // Act
            let result = try decoder.decode(csvWithExtraInfo)
            
            // Assert
            #expect(result != nil)
            #expect(result?.extraInfo[key1] == value1)
            #expect(result?.extraInfo[key2] == value2)
            #expect(result?.extraInfo[key3] == value3)
        }
        
        @Test func testDecodeWhenMissingRequiredFieldsShouldThrowError() {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let missingMessageCSV = "\"\(logLevel)\""
            
            // Act & Assert
            #expect(throws: Error.self) {
                _ = try decoder.decode(missingMessageCSV)
            }
        }
        
        @Test func testDecodeWhenInvalidLogLevelShouldThrowError() {
            // Arrange
            let logLevel = "invalid_level"
            let message = "Message"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let invalidLevelCSV = "\"\(logLevel)\",\"\(message)\""
            
            // Act & Assert
            #expect(throws: Error.self) {
                _ = try decoder.decode(invalidLevelCSV)
            }
        }
        
        @Test func testDecodeWhenEmptyFieldsShouldSetToNil() throws {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let emptyTag = ""
            let emptyThread = ""
            let message = "Message"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .tag, .thread, .message]
            )
            let emptyFieldsCSV = "\"\(logLevel)\",\"\(emptyTag)\",\"\(emptyThread)\",\"\(message)\""
            
            // Act
            let result = try decoder.decode(emptyFieldsCSV)
            
            // Assert
            #expect(result != nil)
            #expect(result?.tag == nil)
            #expect(result?.thread == nil)
            #expect(result?.message == message)
        }
        
        @Test func testDecodeWhenNewlinesInQuotedFieldShouldPreserve() throws {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let message = "Line1\nLine2\nLine3"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .message]
            )
            let multilineCSV = "\"\(logLevel)\",\"\(message)\""
            
            // Act
            let result = try decoder.decode(multilineCSV)
            
            // Assert
            #expect(result != nil)
            #expect(result?.message.contains("\n") ?? false)
        }
        
        @Test func testDecodeWhenDateParsedShouldSetCorrectly() throws {
            // Arrange
            let logLevel = LogLevelDTO.info.rawValue
            let timestamp = "2021-06-15 14:30:00"
            let message = "Message"
            let delimiter = ","
            let dateFormatter = TestData.dateFormatter
            let decoder = LogCSVDecoder(
                delimiter: delimiter,
                dateFormatter: dateFormatter,
                logOptions: [.level, .timestamp, .message]
            )
            let csvWithDate = "\"\(logLevel)\",\"\(timestamp)\",\"\(message)\""
            
            // Act
            let result = try decoder.decode(csvWithDate)
            
            // Assert
            #expect(result != nil)
            #expect(result?.date != nil)
            let dateString = dateFormatter.string(from: result!.date!)
            #expect(dateString == timestamp)
        }
    }
}
