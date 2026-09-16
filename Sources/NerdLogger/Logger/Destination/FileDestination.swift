//
//  FileDestination.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation

/// A ``PersistedLogDestinationProtocol`` implementation that writes encoded records to a file on disk.
///
/// File naming, rotation, and cleanup are delegated to a ``LogFileManagerProtocol`` instance so
/// single-file and rolling-segment strategies can be swapped without changing this class.
/// Concurrent write calls are serialized through the provided ``ExecutionMethod``.
public final class FileDestination: PersistedLogDestinationProtocol {

    // MARK: - Properties(public)

    /// Unique identifier for this destination.
    public let id: String
    /// Filters applied to each record before it is written to disk.
    public var filters: [any LogFilterProtocol]
    /// Encoder that converts a ``LogEntity`` to the file's wire format.
    public let encoder: any LogEncoderProtocol
    /// Optional provider that merges additional metadata into each record before encoding.
    public var metadataProvider: (any LogMetadataProvider)?
    
    // MARK: - Properties(private)

    private let fileManager: any LogFileManagerProtocol
    private let filePermission: String
    private let flushMode: FlushMode
    private let executionMethod: ExecutionMethod
    private let dateFormatter: DateFormatter
    private let onInternalLog: InternalLog?
    private var flushTimer: Timer?
    private var currentHandle: FileHandle?
    private var nextRotationDate: Date?

    // MARK: - Life cycle

    /// Creates a `FileDestination` backed by a `LogFileManager`.
    /// The file manager owns file naming, rotation, and cleanup.
    public init(
        id: String,
        fileManager: any LogFileManagerProtocol,
        filePermission: String,
        flushMode: FlushMode,
        executionMethod: ExecutionMethod,
        dateFormatter: DateFormatter,
        filters: [any LogFilterProtocol],
        encoder: any LogEncoderProtocol,
        metadataProvider: (any LogMetadataProvider)? = nil,
        onInternalLog: InternalLog? = nil
    ) {
        self.id = id
        self.fileManager = fileManager
        self.filePermission = filePermission
        self.flushMode = flushMode
        self.executionMethod = executionMethod
        self.dateFormatter = dateFormatter
        self.filters = filters
        self.encoder = encoder
        self.metadataProvider = metadataProvider
        self.onInternalLog = onInternalLog
    }

    /// Backward-compatible init. Creates a non-rolling `LogFileManager` internally.
    public convenience init(
        id: String,
        containerURL: URL,
        fileName: String,
        filePermission: String,
        flushMode: FlushMode,
        executionMethod: ExecutionMethod,
        dateFormatter: DateFormatter,
        trimDecoder: any LogDecoderProtocol,
        maxLogAge: TimeInterval?,
        maxFileSize: Int?,
        filters: [any LogFilterProtocol],
        encoder: any LogEncoderProtocol,
        metadataProvider: (any LogMetadataProvider)? = nil,
        onInternalLog: InternalLog? = nil
    ) {
        self.init(
            id: id,
            fileManager: LogFileManager(
                containerURL: containerURL,
                baseFileName: fileName,
                segmentDateFormatter: dateFormatter,
                rollingFrequency: nil,
                maxTotalSize: maxFileSize,
                onInternalLog: onInternalLog
            ),
            filePermission: filePermission,
            flushMode: flushMode,
            executionMethod: executionMethod,
            dateFormatter: dateFormatter,
            filters: filters,
            encoder: encoder,
            metadataProvider: metadataProvider,
            onInternalLog: onInternalLog
        )
    }
    
    // MARK: - Methods(public)

    /// Opens the current log file and starts periodic flush timers when configured.
    public func setup() {
        do {
            let fileURL = fileManager.currentFileURL()
            try validateFileURL(fileURL)
            try validateFilePermission(fileURL, filePermission: filePermission)
            try openCurrentFile()
        }
        catch {
            onInternalLog?("Failed to setup file destination: \(error.localizedDescription)")
        }

        fileManager.cleanupOldFiles()
        setupFlushTimerIfNeeded()
    }
    
    /// Encodes and appends `entity` to the current log file, rotating the file when the segment deadline has passed.
    /// - Parameter entity: The log record to persist.
    public func log(_ entity: LogEntity) {
        executionMethod.perform { [weak self] in
            guard let self else {
                return
            }

            do {
                try self.logInternal(entity)
            }
            catch {
                let message = "Failed to log entity: \(entity). Error: \(error.localizedDescription)"
                self.onInternalLog?(message)
            }
        }
    }

    /// Flushes buffered writes to disk by calling `synchronize()` on the open file handle.
    public func flush() {
        do {
            try currentHandle?.synchronize()
        }
        catch {
            onInternalLog?("Failed to flush: \(error.localizedDescription)")
        }
    }

    /// Closes the current file handle and deletes all log files managed by this destination.
    /// - Throws: A ``FileError`` if any file cannot be removed.
    public func deleteAllLogs() throws {
        closeCurrentHandle()
        try fileManager.deleteAllFiles()
    }
    
    // MARK: - Methods(private)
    
    private func logInternal(_ entity: LogEntity) throws {
        for filter in filters where filter.shouldIgnoreLog(entity) {
            onInternalLog?("Log entity ignored by filter in destination: \(self.typeName)")
            return
        }
        
        var entityToLog = entity
        
        if let metadataProvider {
            entityToLog.extraInfo.merge(metadataProvider.metadata) { entityValue, _ in entityValue }
        }
        
        let encodedMessage = try encoder.encode(entityToLog)
        try appendToFile(encodedMessage)
    }
        
    private func setupFlushTimerIfNeeded() {
        flushTimer?.invalidate()
        flushTimer = nil
        
        switch flushMode {
        case .always, .manual:
            break

        case .periodic(let timeInterval):
            flushTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
                self?.flush()
            }
        }
    }
    
    private func validateFileURL(_ url: URL) throws {
        if url.hasDirectoryPath {
            throw FileError.notAFile(at: url)
        }
    }
    
    private func validateFilePermission(_ url: URL, filePermission: String) throws {
        guard let min = UInt16("000", radix: 8) else {
            throw FileError.filePermissionError(at: url, permission: filePermission)
        }
        
        guard let max = UInt16("777", radix: 8) else {
            throw FileError.filePermissionError(at: url, permission: filePermission)
        }
        
        guard let uintPermission = UInt16(filePermission, radix: 8) else {
            throw FileError.filePermissionError(at: url, permission: filePermission)
        }
        
        guard uintPermission >= min, uintPermission <= max else {
            throw FileError.filePermissionError(at: url, permission: filePermission)
        }
        
        onInternalLog?("File permission \(filePermission) validated successfully")
    }
    
    private func appendToFile(_ log: String) throws {
        guard let data = (log + "\r\n").data(using: .utf8) else {
            throw FileError.encodingFailed(message: log)
        }

        try rotateIfNeeded()
        try ensureHandleOpen()

        try currentHandle?.writeCompatible(contentsOf: data)

        if case .always = flushMode {
            try currentHandle?.synchronize()
        }
    }

    private func ensureHandleOpen() throws {
        if currentHandle == nil {
            try openCurrentFile()
        }
    }

    /// Checks if the rotation deadline has passed and reopens the handle for the new segment.
    private func rotateIfNeeded() throws {
        guard let deadline = nextRotationDate, Date() >= deadline else {
            return
        }

        closeCurrentHandle()
        try openCurrentFile()
        fileManager.cleanupOldFiles()
    }

    private func openCurrentFile() throws {
        let fileURL = fileManager.currentFileURL()
        try fileManager.ensureCurrentFileExists(permission: filePermission)
        let handle = try FileHandle(forWritingTo: fileURL)
        try handle.seekToEndCompatible()
        currentHandle = handle
        nextRotationDate = fileManager.nextRotationDate()
        onInternalLog?("Opened log file: \(fileURL.lastPathComponent)")
    }

    private func closeCurrentHandle() {
        try? currentHandle?.synchronize()
        try? currentHandle?.close()
        currentHandle = nil
    }
}

extension FileDestination: TypeNameProtocol {}
