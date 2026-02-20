//
//  Thread+Number.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 19.06.2025.
//

import Foundation

extension Thread {
    class var threadId: UInt64 {
        var threadId: UInt64 = 0
        pthread_threadid_np(nil, &threadId)
        return threadId
    }
}
