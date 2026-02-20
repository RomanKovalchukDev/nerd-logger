//
//  CallbackCaptor.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 30.12.2025.
//

import Foundation

/// Thread-safe helper for capturing callback invocations in tests.
final class CallbackCaptor: @unchecked Sendable {
    private let lock = NSLock()
    private var capturedMessages: [String] = []
    
    var messages: [String] {
        lock.lock()
        defer { lock.unlock() }
        return capturedMessages
    }
    
    var callCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return capturedMessages.count
    }
    
    var lastMessage: String? {
        lock.lock()
        defer { lock.unlock() }
        return capturedMessages.last
    }
    
    func capture(_ message: String) {
        lock.lock()
        defer { lock.unlock() }
        capturedMessages.append(message)
    }
    
    func reset() {
        lock.lock()
        defer { lock.unlock() }
        capturedMessages.removeAll()
    }
}
