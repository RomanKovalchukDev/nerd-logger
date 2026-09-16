//
//  LogFileManager.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 22.04.2026.
//

import Foundation

/// Manages log file naming, rotation, enumeration, and cleanup.
///
/// Inspired by CocoaLumberjack's `DDLogFileManager`, this type is the single source of truth
/// for file path resolution. It is shared between the writer (`FileDestination`),
/// the reader (`SegmentedLogFetcher`), and cleanup callers.
///
/// Rolling behavior is configuration-driven:
/// - `rollingFrequency == nil` or `0`: single file mode (current `FileDestination` behavior).
/// - `rollingFrequency == 86400`: daily segments (`baseName_YYYY-MM-DD.ext`).
public final class LogFileManager: LogFileManagerProtocol {

    // MARK: - Internal types

    private typealias Segment = (url: URL, dateString: String, fileSize: Int)

    // MARK: - Properties(public)

    /// Directory where log files are created.
    public let containerURL: URL
    /// Base file name used to derive segment file names (for example `"app.log"`).
    public let baseFileName: String
    /// Segment duration in seconds. `nil` or `0` disables rolling; `86400` produces daily files.
    public let rollingFrequency: TimeInterval?
    /// Maximum number of segment files to retain. Oldest segments are deleted when this limit is exceeded.
    public let maxFileCount: Int?
    /// Maximum total size in bytes for all segment files. Oldest segments are deleted until total size drops below 80% of this value.
    public let maxTotalSize: Int?

    // MARK: - Properties(private)

    private let segmentDateFormatter: DateFormatter
    private let baseNameWithoutExtension: String
    private let baseFileExtension: String
    private let onInternalLog: InternalLog?

    // MARK: - Properties(computed)

    /// `true` when rolling is active (i.e., `rollingFrequency` is set and greater than zero).
    public var isRolling: Bool {
        guard let frequency = rollingFrequency else {
            return false
        }
        return frequency > 0
    }

    // MARK: - Life cycle

    /// Creates a log file manager.
    /// - Parameters:
    ///   - containerURL: Directory in which log files are created.
    ///   - baseFileName: File name template (for example `"dns.log"`).
    ///   - segmentDateFormatter: Formatter whose output is appended to the base name for each segment.
    ///   - rollingFrequency: Segment duration in seconds. `nil` or `0` disables rolling.
    ///   - maxFileCount: Maximum number of retained segment files. `nil` means unlimited.
    ///   - maxTotalSize: Maximum total size of retained segment files in bytes. `nil` means unlimited.
    ///   - onInternalLog: Optional closure that receives diagnostic messages from the manager itself.
    public init(
        containerURL: URL,
        baseFileName: String,
        segmentDateFormatter: DateFormatter,
        rollingFrequency: TimeInterval? = nil,
        maxFileCount: Int? = nil,
        maxTotalSize: Int? = nil,
        onInternalLog: InternalLog? = nil
    ) {
        self.containerURL = containerURL
        self.baseFileName = baseFileName
        self.rollingFrequency = rollingFrequency
        self.maxFileCount = maxFileCount
        self.maxTotalSize = maxTotalSize
        self.segmentDateFormatter = segmentDateFormatter
        self.baseNameWithoutExtension = (baseFileName as NSString).deletingPathExtension
        self.baseFileExtension = (baseFileName as NSString).pathExtension
        self.onInternalLog = onInternalLog
    }
    
    // MARK: - Methods(static)

    /// Derives a segment file name by inserting `dateString` before the extension of `baseName`.
    ///
    /// For example, `"dns.log"` and `"2026-04-22"` produce `"dns_2026-04-22.log"`.
    /// - Parameters:
    ///   - baseName: The base file name including extension (for example `"app.log"`).
    ///   - dateString: The date string to embed in the file name.
    /// - Returns: The segmented file name.
    public static func segmentedFileName(baseName: String, dateString: String) -> String {
        let name = (baseName as NSString).deletingPathExtension
        let ext = (baseName as NSString).pathExtension
        return ext.isEmpty ? "\(name)_\(dateString)" : "\(name)_\(dateString).\(ext)"
    }

    // MARK: - Methods(public)

    /// Returns the URL to write to right now.
    public func currentFileURL() -> URL {
        guard isRolling else {
            return containerURL.appendingPathComponent(baseFileName)
        }

        let dateString = segmentDateFormatter.string(from: Date())
        let segmentName = Self.segmentedFileName(baseName: baseFileName, dateString: dateString)
        return containerURL.appendingPathComponent(segmentName)
    }

    /// The date at which the current segment expires and a new file should be opened.
    ///
    /// Returns `nil` when rolling is disabled.
    public func nextRotationDate() -> Date? {
        guard isRolling else {
            return nil
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = segmentDateFormatter.timeZone

        return calendar.startOfDay(for: Date()).addingTimeInterval(rollingFrequency ?? 86_400)
    }

    /// All log file URLs matching this manager's naming pattern, sorted oldest-first.
    /// In rolling mode, also includes the base file if it exists (migration fallback).
    public func sortedLogFileURLs() -> [URL] {
        let fileManager = FileManager.default

        guard isRolling else {
            let fileURL = containerURL.appendingPathComponent(baseFileName)
            return fileManager.fileExists(atPath: fileURL.path) ? [fileURL] : []
        }

        guard let contents = try? fileManager.contentsOfDirectory(
            at: containerURL,
            includingPropertiesForKeys: [.nameKey]
        ) else {
            return []
        }

        let prefix = baseNameWithoutExtension + "_"
        let ext = baseFileExtension

        var segmentFiles = contents.filter { url in
            let name = url.lastPathComponent
            return name.hasPrefix(prefix) && (ext.isEmpty || name.hasSuffix(".\(ext)"))
        }

        segmentFiles.sort { $0.lastPathComponent < $1.lastPathComponent }

        // Include the legacy base file if it exists (migration support)
        let legacyURL = containerURL.appendingPathComponent(baseFileName)
        if fileManager.fileExists(atPath: legacyURL.path) {
            segmentFiles.insert(legacyURL, at: 0)
        }

        return segmentFiles
    }

    /// Ensures the current file and its parent directory exist.
    public func ensureCurrentFileExists(permission: String) throws {
        let fileURL = currentFileURL()

        do {
            try FileManager.default.createDirectory(
                at: containerURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        catch {
            throw FileError.fileCreationFailed(at: containerURL, underlyingError: error)
        }

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            guard let uintPermission = UInt16(permission, radix: 8) else {
                throw FileError.filePermissionError(at: fileURL, permission: permission)
            }

            let successful = FileManager.default.createFile(
                atPath: fileURL.path,
                contents: nil,
                attributes: [FileAttributeKey.posixPermissions: uintPermission]
            )

            guard successful else {
                throw FileError.fileCreationFailed(at: fileURL, underlyingError: FileError.unknownError)
            }

            onInternalLog?("Created log file at: \(fileURL.path)")
        }
    }

    /// Removes segment files exceeding `maxFileCount` and enforces `maxTotalSize`.
    /// Skips today's file. No-op when `isRolling` is false.
    public func cleanupOldFiles() {
        guard isRolling else {
            return
        }

        var segments = collectCleanableSegments()
        removeExcessSegments(&segments)
        removeOversizedSegments(segments)
    }

    /// Deletes all log files matching this manager's pattern.
    public func deleteAllFiles() throws {
        let fileManager = FileManager.default

        guard isRolling else {
            let fileURL = containerURL.appendingPathComponent(baseFileName)

            guard fileManager.fileExists(atPath: fileURL.path) else {
                return
            }

            do {
                try fileManager.removeItem(at: fileURL)
            }
            catch {
                throw FileError.fileDeletionFailed(at: fileURL, underlyingError: error)
            }

            return
        }

        let prefix = baseNameWithoutExtension + "_"
        let ext = baseFileExtension

        guard let contents = try? fileManager.contentsOfDirectory(
            at: containerURL,
            includingPropertiesForKeys: [.nameKey]
        ) else {
            return
        }

        var lastError: Error?

        for file in contents {
            let name = file.lastPathComponent

            let isSegment = name.hasPrefix(prefix) && (ext.isEmpty || name.hasSuffix(".\(ext)"))
            let isBaseFile = name == baseFileName

            guard isSegment || isBaseFile else { continue }

            do {
                try fileManager.removeItem(at: file)
            }
            catch {
                lastError = error
            }
        }

        if let lastError {
            throw FileError.fileDeletionFailed(at: containerURL, underlyingError: lastError)
        }
    }

    // MARK: - Methods(private)

    /// Lists all segment files eligible for cleanup (excludes today's file).
    private func collectCleanableSegments() -> [Segment] {
        let prefix = baseNameWithoutExtension + "_"
        let ext = baseFileExtension
        let todayString = segmentDateFormatter.string(from: Date())
        let todayFileName = Self.segmentedFileName(baseName: baseFileName, dateString: todayString)

        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: containerURL,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else {
            return []
        }

        var segments: [Segment] = []

        for file in contents {
            let name = file.lastPathComponent
            guard name.hasPrefix(prefix) else { continue }
            guard ext.isEmpty || name.hasSuffix(".\(ext)") else { continue }
            guard name != todayFileName else { continue }

            let nameWithoutExt = (name as NSString).deletingPathExtension
            let dateString = String(nameWithoutExt.dropFirst(prefix.count))
            let size = (try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            segments.append((url: file, dateString: dateString, fileSize: size))
        }

        return segments
    }

    /// Keeps only the most recent `maxFileCount` segments, deletes the rest.
    private func removeExcessSegments(_ segments: inout [Segment]) {
        guard let maxCount = maxFileCount, segments.count > maxCount else {
            return
        }

        let sorted = segments.sorted { $0.dateString < $1.dateString }
        let excessCount = sorted.count - maxCount
        let toRemove = sorted.prefix(excessCount)

        for segment in toRemove {
            do {
                try FileManager.default.removeItem(at: segment.url)
                onInternalLog?("Removed excess segment: \(segment.url.lastPathComponent)")
            }
            catch {
                onInternalLog?("Failed to remove excess segment: \(error.localizedDescription)")
            }
        }

        let removedDates = Set(toRemove.map(\.dateString))
        segments.removeAll { removedDates.contains($0.dateString) }
    }

    /// Deletes oldest segments until total size is under 80% of `maxTotalSize`.
    private func removeOversizedSegments(_ segments: [Segment]) {
        guard let maxSize = maxTotalSize else {
            return
        }

        let totalSize = segments.reduce(0) { $0 + $1.fileSize }

        guard totalSize > maxSize else {
            return
        }

        let sortedByDate = segments.sorted { $0.dateString < $1.dateString }
        var currentSize = totalSize
        let targetSize = Int(Double(maxSize) * 0.8)

        for segment in sortedByDate {
            guard currentSize > targetSize else {
                break
            }

            do {
                try FileManager.default.removeItem(at: segment.url)
                currentSize -= segment.fileSize
                onInternalLog?("Removed segment for size: \(segment.url.lastPathComponent)")
            }
            catch {
                onInternalLog?("Failed to remove segment for size: \(error.localizedDescription)")
            }
        }
    }
}
