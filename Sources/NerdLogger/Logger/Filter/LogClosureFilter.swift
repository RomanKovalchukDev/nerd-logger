//
//  LogClosureFilter.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

public struct LogClosureFilter: LogFilterProtocol {
    
    public let id: String
    private let onFilter: (LogEntity) -> Bool
    
    public init(id: String, onFilter: @escaping (LogEntity) -> Bool) {
        self.id = id
        self.onFilter = onFilter
    }
    
    public func shouldIgnoreLog(_ entity: LogEntity) -> Bool {
        onFilter(entity)
    }
}
