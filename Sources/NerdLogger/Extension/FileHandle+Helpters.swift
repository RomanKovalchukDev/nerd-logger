//
//  FileHandle+Helpters.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 29.12.2025.
//

import Foundation

extension FileHandle {
    @discardableResult
    func seekToEndCompatible() throws -> UInt64 {
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, visionOS 1.0, macCatalyst 13.4, *) {
            return try seekToEnd()
        }
        else {
            return seekToEndOfFile()
        }
    }

    func writeCompatible(contentsOf data: Data) throws {
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, visionOS 1.0, macCatalyst 13.4, *) {
            try write(contentsOf: data)
        }
        else {
            write(data)
        }
    }
}
