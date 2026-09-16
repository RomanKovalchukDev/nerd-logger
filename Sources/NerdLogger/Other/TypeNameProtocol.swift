//
//  TypeNameProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 06.01.2026.
//

/// A protocol that exposes a human-readable name for a type, both statically and per instance.
///
/// Conforming types get a default implementation from ``TypeNameProtocol/typeName-swift.type.property``
/// that uses `String(describing:)`. Used throughout the logging pipeline to identify filters
/// and destinations in diagnostic messages.
public protocol TypeNameProtocol {
    /// The static name of the conforming type.
    static var typeName: String { get }

    /// The dynamic name of the conforming instance's type.
    var typeName: String { get }
}
