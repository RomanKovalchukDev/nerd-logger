//
//  FileTestHelpers.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 31.12.2025.
//

import Foundation

enum FileTestHelpers {
    static func createTemporaryDirectory() -> URL {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }
    
    static func cleanup(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
