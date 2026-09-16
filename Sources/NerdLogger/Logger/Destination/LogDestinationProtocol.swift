//
//  LogDestinationProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

/// A sink that receives ``LogEntity`` values and writes them to an output medium.
///
/// Destinations are registered with a ``LogProtocol`` implementation. Each record is
/// pre-processed through `filters` before being encoded and written.
public protocol LogDestinationProtocol {
    /// Unique identifier used to prevent duplicate registration and for targeted removal.
    var id: String { get }

    /// Ordered list of filters applied to each record before encoding. A record is dropped if any filter returns `true` from ``LogFilterProtocol/shouldIgnoreLog(_:)``.
    var filters: [any LogFilterProtocol] { get set }

    /// Encoder that converts a ``LogEntity`` to the destination's wire format.
    var encoder: any LogEncoderProtocol { get }

    /// Optional provider that merges additional key-value pairs into each record's `extraInfo` before encoding.
    var metadataProvider: (any LogMetadataProvider)? { get set }

    /// Writes `entity` to the underlying output medium.
    /// - Parameter entity: The log record to write.
    func log(_ entity: LogEntity)
}
