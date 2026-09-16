//
//  FileError.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation

/// Errors raised by file-backed logging operations.
public enum FileError: Error {
    /// The provided URL refers to a directory rather than a regular file.
    case notAFile(at: URL)

    /// The provided POSIX permission string is malformed or outside the valid range.
    case filePermissionError(at: URL, permission: String)

    /// A log file could not be created at the given URL.
    case fileCreationFailed(at: URL, underlyingError: Error)

    /// A log file could not be opened for reading or writing.
    case fileOpenFailed(at: URL, underlyingError: Error)

    /// A log file or directory could not be removed.
    case fileDeletionFailed(at: URL, underlyingError: Error)

    /// A log message could not be encoded to UTF-8 bytes.
    case encodingFailed(message: String)

    /// An unspecified failure occurred inside the file layer.
    case unknownError
}
