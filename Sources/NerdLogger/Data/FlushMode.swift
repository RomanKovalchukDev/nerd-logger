//
//  FlushMode.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 29.12.2025.
//

import Foundation

/// Controls how a file-backed log destination synchronizes buffered writes to disk.
public enum FlushMode {
    /// Flush after every write. Safest but slowest.
    case always

    /// Never flush automatically. Callers must invoke `flush()` explicitly.
    case manual

    /// Flush on a repeating timer with the given interval, in seconds.
    case periodic(TimeInterval)
}
