//
//  LogEncoderProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

/// Encodes a ``LogEntity`` into its wire representation for a destination.
///
/// Concrete encoders decide format (JSON, CSV, plain text) and which ``LogOption``
/// fields are included in the output.
public protocol LogEncoderProtocol {
    /// Encodes the given entity to a string suitable for writing to a destination.
    /// - Parameter entity: The record to serialize.
    /// - Returns: The encoded representation of `entity`.
    /// - Throws: An `EncodingError` if the record cannot be encoded.
    func encode(_ entity: LogEntity) throws -> String
}
