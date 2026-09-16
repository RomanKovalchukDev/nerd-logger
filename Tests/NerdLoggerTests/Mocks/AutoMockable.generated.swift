// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif


@testable import NerdLogger

public class LogDecoderProtocolMock: LogDecoderProtocol {

    public init() {}



    //MARK: - decode

    public var decodeStringStringLogEntityThrowableError: (any Error)?
    public var decodeStringStringLogEntityCallsCount = 0
    public var decodeStringStringLogEntityCalled: Bool {
        return decodeStringStringLogEntityCallsCount > 0
    }
    public var decodeStringStringLogEntityReceivedString: (String)?
    public var decodeStringStringLogEntityReceivedInvocations: [(String)] = []
    public var decodeStringStringLogEntityReturnValue: LogEntity?
    public var decodeStringStringLogEntityClosure: ((String) throws -> LogEntity?)?

    public func decode(_ string: String) throws -> LogEntity? {
        decodeStringStringLogEntityCallsCount += 1
        decodeStringStringLogEntityReceivedString = string
        decodeStringStringLogEntityReceivedInvocations.append(string)
        if let error = decodeStringStringLogEntityThrowableError {
            throw error
        }
        if let decodeStringStringLogEntityClosure = decodeStringStringLogEntityClosure {
            return try decodeStringStringLogEntityClosure(string)
        } else {
            return decodeStringStringLogEntityReturnValue
        }
    }

    //MARK: - splitContent

    public var splitContentContentStringStringCallsCount = 0
    public var splitContentContentStringStringCalled: Bool {
        return splitContentContentStringStringCallsCount > 0
    }
    public var splitContentContentStringStringReceivedContent: (String)?
    public var splitContentContentStringStringReceivedInvocations: [(String)] = []
    public var splitContentContentStringStringReturnValue: [String]!
    public var splitContentContentStringStringClosure: ((String) -> [String])?

    public func splitContent(_ content: String) -> [String] {
        splitContentContentStringStringCallsCount += 1
        splitContentContentStringStringReceivedContent = content
        splitContentContentStringStringReceivedInvocations.append(content)
        if let splitContentContentStringStringClosure = splitContentContentStringStringClosure {
            return splitContentContentStringStringClosure(content)
        } else {
            return splitContentContentStringStringReturnValue
        }
    }


}
public class LogEncoderProtocolMock: LogEncoderProtocol {

    public init() {}



    //MARK: - encode

    public var encodeEntityLogEntityStringThrowableError: (any Error)?
    public var encodeEntityLogEntityStringCallsCount = 0
    public var encodeEntityLogEntityStringCalled: Bool {
        return encodeEntityLogEntityStringCallsCount > 0
    }
    public var encodeEntityLogEntityStringReceivedEntity: (LogEntity)?
    public var encodeEntityLogEntityStringReceivedInvocations: [(LogEntity)] = []
    public var encodeEntityLogEntityStringReturnValue: String!
    public var encodeEntityLogEntityStringClosure: ((LogEntity) throws -> String)?

    public func encode(_ entity: LogEntity) throws -> String {
        encodeEntityLogEntityStringCallsCount += 1
        encodeEntityLogEntityStringReceivedEntity = entity
        encodeEntityLogEntityStringReceivedInvocations.append(entity)
        if let error = encodeEntityLogEntityStringThrowableError {
            throw error
        }
        if let encodeEntityLogEntityStringClosure = encodeEntityLogEntityStringClosure {
            return try encodeEntityLogEntityStringClosure(entity)
        } else {
            return encodeEntityLogEntityStringReturnValue
        }
    }


}
public class LogFetcherProtocolMock: LogFetcherProtocol {

    public init() {}

    public var decoder: any LogDecoderProtocol {
        get { return underlyingDecoder }
        set(value) { underlyingDecoder = value }
    }
    public var underlyingDecoder: (any LogDecoderProtocol)!


    //MARK: - fetchLogs

    public var fetchLogsWithFilterLogFetcherFilterLogEntityThrowableError: (any Error)?
    public var fetchLogsWithFilterLogFetcherFilterLogEntityCallsCount = 0
    public var fetchLogsWithFilterLogFetcherFilterLogEntityCalled: Bool {
        return fetchLogsWithFilterLogFetcherFilterLogEntityCallsCount > 0
    }
    public var fetchLogsWithFilterLogFetcherFilterLogEntityReceivedFilter: ((LogFetcherFilter))?
    public var fetchLogsWithFilterLogFetcherFilterLogEntityReceivedInvocations: [((LogFetcherFilter))?] = []
    public var fetchLogsWithFilterLogFetcherFilterLogEntityReturnValue: [LogEntity]!
    public var fetchLogsWithFilterLogFetcherFilterLogEntityClosure: ((LogFetcherFilter?) throws -> [LogEntity])?

    public func fetchLogs(with filter: LogFetcherFilter?) throws -> [LogEntity] {
        fetchLogsWithFilterLogFetcherFilterLogEntityCallsCount += 1
        fetchLogsWithFilterLogFetcherFilterLogEntityReceivedFilter = filter
        fetchLogsWithFilterLogFetcherFilterLogEntityReceivedInvocations.append(filter)
        if let error = fetchLogsWithFilterLogFetcherFilterLogEntityThrowableError {
            throw error
        }
        if let fetchLogsWithFilterLogFetcherFilterLogEntityClosure = fetchLogsWithFilterLogFetcherFilterLogEntityClosure {
            return try fetchLogsWithFilterLogFetcherFilterLogEntityClosure(filter)
        } else {
            return fetchLogsWithFilterLogFetcherFilterLogEntityReturnValue
        }
    }


}
public class LogMetadataProviderMock: LogMetadataProvider {

    public init() {}

    public var metadata: [String: String] = [:]



}
public class LogProtocolMock: LogProtocol {

    public init() {}

    public var destinations: [any LogDestinationProtocol] = []


    //MARK: - addDestination

    public var addDestinationDestinationAnyLogDestinationProtocolVoidCallsCount = 0
    public var addDestinationDestinationAnyLogDestinationProtocolVoidCalled: Bool {
        return addDestinationDestinationAnyLogDestinationProtocolVoidCallsCount > 0
    }
    public var addDestinationDestinationAnyLogDestinationProtocolVoidReceivedDestination: (any LogDestinationProtocol)?
    public var addDestinationDestinationAnyLogDestinationProtocolVoidReceivedInvocations: [(any LogDestinationProtocol)] = []
    public var addDestinationDestinationAnyLogDestinationProtocolVoidClosure: ((any LogDestinationProtocol) -> Void)?

    public func addDestination(_ destination: any LogDestinationProtocol) {
        addDestinationDestinationAnyLogDestinationProtocolVoidCallsCount += 1
        addDestinationDestinationAnyLogDestinationProtocolVoidReceivedDestination = destination
        addDestinationDestinationAnyLogDestinationProtocolVoidReceivedInvocations.append(destination)
        addDestinationDestinationAnyLogDestinationProtocolVoidClosure?(destination)
    }

    //MARK: - removeDestinationWithID

    public var removeDestinationWithIDIdStringVoidCallsCount = 0
    public var removeDestinationWithIDIdStringVoidCalled: Bool {
        return removeDestinationWithIDIdStringVoidCallsCount > 0
    }
    public var removeDestinationWithIDIdStringVoidReceivedId: (String)?
    public var removeDestinationWithIDIdStringVoidReceivedInvocations: [(String)] = []
    public var removeDestinationWithIDIdStringVoidClosure: ((String) -> Void)?

    public func removeDestinationWithID(_ id: String) {
        removeDestinationWithIDIdStringVoidCallsCount += 1
        removeDestinationWithIDIdStringVoidReceivedId = id
        removeDestinationWithIDIdStringVoidReceivedInvocations.append(id)
        removeDestinationWithIDIdStringVoidClosure?(id)
    }

    //MARK: - removeAllDestinations

    public var removeAllDestinationsVoidCallsCount = 0
    public var removeAllDestinationsVoidCalled: Bool {
        return removeAllDestinationsVoidCallsCount > 0
    }
    public var removeAllDestinationsVoidClosure: (() -> Void)?

    public func removeAllDestinations() {
        removeAllDestinationsVoidCallsCount += 1
        removeAllDestinationsVoidClosure?()
    }

    //MARK: - log

    public var logMessageStringLogLevelLogLevelDateDateTagStringFileNameStringFunctionNameStringLineNumberUIntExtraInfoStringStringVoidCallsCount = 0
    public var logMessageStringLogLevelLogLevelDateDateTagStringFileNameStringFunctionNameStringLineNumberUIntExtraInfoStringStringVoidCalled: Bool {
        return logMessageStringLogLevelLogLevelDateDateTagStringFileNameStringFunctionNameStringLineNumberUIntExtraInfoStringStringVoidCallsCount > 0
    }
    public var logMessageStringLogLevelLogLevelDateDateTagStringFileNameStringFunctionNameStringLineNumberUIntExtraInfoStringStringVoidReceivedArguments: (message: String, logLevel: LogLevel, date: Date, tag: String?, fileName: String, functionName: String, lineNumber: UInt, extraInfo: [String: String])?
    public var logMessageStringLogLevelLogLevelDateDateTagStringFileNameStringFunctionNameStringLineNumberUIntExtraInfoStringStringVoidReceivedInvocations: [(message: String, logLevel: LogLevel, date: Date, tag: String?, fileName: String, functionName: String, lineNumber: UInt, extraInfo: [String: String])] = []
    public var logMessageStringLogLevelLogLevelDateDateTagStringFileNameStringFunctionNameStringLineNumberUIntExtraInfoStringStringVoidClosure: ((String, LogLevel, Date, String?, String, String, UInt, [String: String]) -> Void)?

    public func log(_ message: String, logLevel: LogLevel, date: Date, tag: String?, fileName: String, functionName: String, lineNumber: UInt, extraInfo: [String: String]) {
        logMessageStringLogLevelLogLevelDateDateTagStringFileNameStringFunctionNameStringLineNumberUIntExtraInfoStringStringVoidCallsCount += 1
        logMessageStringLogLevelLogLevelDateDateTagStringFileNameStringFunctionNameStringLineNumberUIntExtraInfoStringStringVoidReceivedArguments = (message: message, logLevel: logLevel, date: date, tag: tag, fileName: fileName, functionName: functionName, lineNumber: lineNumber, extraInfo: extraInfo)
        logMessageStringLogLevelLogLevelDateDateTagStringFileNameStringFunctionNameStringLineNumberUIntExtraInfoStringStringVoidReceivedInvocations.append((message: message, logLevel: logLevel, date: date, tag: tag, fileName: fileName, functionName: functionName, lineNumber: lineNumber, extraInfo: extraInfo))
        logMessageStringLogLevelLogLevelDateDateTagStringFileNameStringFunctionNameStringLineNumberUIntExtraInfoStringStringVoidClosure?(message, logLevel, date, tag, fileName, functionName, lineNumber, extraInfo)
    }

    //MARK: - setupAllDestinations

    public var setupAllDestinationsVoidCallsCount = 0
    public var setupAllDestinationsVoidCalled: Bool {
        return setupAllDestinationsVoidCallsCount > 0
    }
    public var setupAllDestinationsVoidClosure: (() -> Void)?

    public func setupAllDestinations() {
        setupAllDestinationsVoidCallsCount += 1
        setupAllDestinationsVoidClosure?()
    }

    //MARK: - flushAllDestinations

    public var flushAllDestinationsVoidCallsCount = 0
    public var flushAllDestinationsVoidCalled: Bool {
        return flushAllDestinationsVoidCallsCount > 0
    }
    public var flushAllDestinationsVoidClosure: (() -> Void)?

    public func flushAllDestinations() {
        flushAllDestinationsVoidCallsCount += 1
        flushAllDestinationsVoidClosure?()
    }


}
