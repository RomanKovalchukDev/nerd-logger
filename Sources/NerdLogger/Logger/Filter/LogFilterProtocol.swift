//
//  LogFilterProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

public protocol LogFilterProtocol: TypeNameProtocol {
    var id: String { get }
    
    func shouldIgnoreLog(_ entity: LogEntity) -> Bool
}
