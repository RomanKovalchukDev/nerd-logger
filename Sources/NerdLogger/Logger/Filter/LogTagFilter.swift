//
//  LogTagFilter.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

public struct LogTagFilter: LogFilterProtocol {
    
    public let id: String
    public let tags: [String]
    
    public init(id: String, tags: [String]) {
        self.id = id
        self.tags = tags
    }
    
    public func shouldIgnoreLog(_ entity: LogEntity) -> Bool {
        guard let entityTag = entity.tag else {
            return true
        }
        
        return !tags.contains(entityTag)
    }
}
