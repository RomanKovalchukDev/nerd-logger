//
//  LogProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 15.09.2025.
//

// swiftlint:disable function_parameter_count

import Foundation

public protocol LogProtocol {
    var destinations: [any LogDestinationProtocol] { get }
    
    func addDestination(_ destination: any LogDestinationProtocol)
    func removeDestinationWithID(_ id: String)
    func removeAllDestinations()
    
    func log(
        _ message: String,
        logLevel: LogLevel,
        date: Date,
        tag: String?,
        fileName: String,
        functionName: String,
        lineNumber: UInt,
        extraInfo: [String: String]
    )
    
    func setupAllDestinations()
    func flushAllDestinations()
}
