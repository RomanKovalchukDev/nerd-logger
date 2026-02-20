//
//  FileError.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation

public enum FileError: Error {
    case notAFile(at: URL)
    case filePermissionError(at: URL, permission: String)
    case fileCreationFailed(at: URL, underlyingError: Error)
    case fileOpenFailed(at: URL, underlyingError: Error)
    case fileDeletionFailed(at: URL, underlyingError: Error)
    case encodingFailed(message: String)
    case unknownError
}
