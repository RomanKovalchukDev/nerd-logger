//
//  FileHandle+Helpters.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 29.12.2025.
//

import Foundation

extension FileHandle {
    /// Seeks to the end of the file using the modern API when available, falling back to the legacy API on older systems.
    /// - Returns: The new byte offset from the start of the file.
    /// - Throws: An error if the seek operation fails.
    @discardableResult
    func seekToEndCompatible() throws -> UInt64 {
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, visionOS 1.0, macCatalyst 13.4, *) {
            return try seekToEnd()
        }
        else {
            return seekToEndOfFile()
        }
    }

    /// Writes the given data to the file using the modern throwing API when available, falling back to the legacy API on older systems.
    /// - Parameter data: The bytes to append at the current file offset.
    /// - Throws: An error if the write operation fails.
    func writeCompatible(contentsOf data: Data) throws {
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, visionOS 1.0, macCatalyst 13.4, *) {
            try write(contentsOf: data)
        }
        else {
            write(data)
        }
    }
}
