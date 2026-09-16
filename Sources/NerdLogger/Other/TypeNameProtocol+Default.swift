//
//  TypeNameProtocol+Default.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 06.01.2026.
//

/// Default `typeName` implementations satisfied by `String(describing:)`.
public extension TypeNameProtocol {
    /// Default implementation returning `String(describing: Self.self)`.
    static var typeName: String {
        String(describing: Self.self)
    }

    /// Default implementation returning `String(describing: type(of: self))`.
    var typeName: String {
        String(describing: type(of: self))
    }
}
