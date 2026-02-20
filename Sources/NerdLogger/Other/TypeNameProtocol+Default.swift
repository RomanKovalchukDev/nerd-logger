//
//  TypeNameProtocol+Default.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 06.01.2026.
//

public extension TypeNameProtocol {
    static var typeName: String {
        String(describing: Self.self)
    }
    
    var typeName: String {
        String(describing: type(of: self))
    }
}
