//
//  FileDestination.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation

public final class FileDestination: PersistedLogDestinationProtocol {
    
    // MARK: - Properties(public)
    
    public let id: String
    public var filters: [any LogFilterProtocol]
    public let encoder: any LogEncoderProtocol
    public var metadataProvider: (any LogMetadataProvider)?
    
    // MARK: - Properties(private)
    
    private let containerURL: URL
    private let fileName: String
    private let filePermission: String
    private let flushMode: FlushMode
    private let executionMethod: ExecutionMethod
    private let dateFormatter: DateFormatter
    private let trimDecoder: any LogDecoderProtocol
    private let maxLogAge: TimeInterval?
    private let maxFileSize: Int?
    private let onInternalLog: InternalLog?
    private var flushTimer: Timer?
    
    private var uintPermission: UInt16? {
        UInt16(filePermission, radix: 8)
    }
    
    // MARK: - Life cycle
    
    public init(
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
        self.id = id
        self.containerURL = containerURL
        self.fileName = fileName
        self.filePermission = filePermission
        self.flushMode = flushMode
        self.executionMethod = executionMethod
        self.dateFormatter = dateFormatter
        self.trimDecoder = trimDecoder
        self.maxLogAge = maxLogAge
        self.maxFileSize = maxFileSize
        self.filters = filters
        self.encoder = encoder
        self.metadataProvider = metadataProvider
        self.onInternalLog = onInternalLog
    }
    
    // MARK: - Methods(public)
    
    public func setup() {
        let fileURL = containerURL.appendingPathComponent(fileName)
        
        do {
            try validateFileURL(fileURL)
            try validateFilePermission(fileURL, filePermission: filePermission)
            try openFile()
            
            trimLogsIfNeeded()
        }
        catch {
            onInternalLog?("Failed to setup file destination: \(error.localizedDescription)")
        }
        
        setupFlushTimerIfNeeded()
    }
    
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
    
    public func flush() {
        let fileURL = containerURL.appendingPathComponent(fileName)
        
        do {
            let handle = try FileHandle(forWritingTo: fileURL)
            try handle.synchronize()
            try handle.close()
        }
        catch {
            onInternalLog?("Failed to flush: \(error.localizedDescription)")
        }
    }
    
    public func deleteAllLogs() throws {
        let fileURL = containerURL.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        }
        catch {
            throw FileError.fileDeletionFailed(at: fileURL, underlyingError: error)
        }
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
    
    private func openFile() throws {
        guard let uintPermission else {
            throw FileError.filePermissionError(at: containerURL, permission: filePermission)
        }
        
        let directoryURL = containerURL
        let fileURL = containerURL.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        catch {
            throw FileError.fileCreationFailed(at: directoryURL, underlyingError: error)
        }
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
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
        else {
            onInternalLog?("Using existing log file at: \(fileURL.path)")
        }
        
        do {
            let handle = try FileHandle(forWritingTo: fileURL)
            try handle.synchronize()
            try handle.close()
        }
        catch {
            throw FileError.fileOpenFailed(at: fileURL, underlyingError: error)
        }
    }
    
    private func appendToFile(_ log: String) throws {
        let fileURL = containerURL.appendingPathComponent(fileName)
        
        let handle = try FileHandle(forWritingTo: fileURL)
        try handle.seekToEndCompatible()
        
        guard let data = (log + "\r\n").data(using: .utf8) else {
            throw FileError.encodingFailed(message: log)
        }
        
        try handle.writeCompatible(contentsOf: data)
        
        if case .always = flushMode {
            try handle.synchronize()
        }
        
        try handle.close()
    }
    
    private func trimLogsIfNeeded() {
        executionMethod.perform { [weak self] in
            guard let self else {
                return
            }
            
            let fileURL = self.containerURL.appendingPathComponent(self.fileName)
            
            do {
                // Always trim invalid lines first
                try self.trimInvalidLogs(fileURL: fileURL)
                
                if let maxFileSize = self.maxFileSize {
                    try self.trimLogsByFileSize(fileURL: fileURL, maxSize: maxFileSize)
                }
                
                if let maxLogAge = self.maxLogAge {
                    try self.trimLogsByAge(fileURL: fileURL, maxAge: maxLogAge)
                }
            }
            catch {
                self.onInternalLog?("Failed to trim logs: \(error.localizedDescription)")
            }
        }
    }
    
    /// Removes all invalid log entries that cannot be decoded.
    private func trimInvalidLogs(fileURL: URL) throws {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = trimDecoder.splitContent(content)
        
        var keptLines: [String] = []
        var invalidLinesCount = 0
        
        for line in lines {
            do {
                guard try trimDecoder.decode(line) != nil else {
                    invalidLinesCount += 1
                    continue
                }
                keptLines.append(line)
            } catch {
                invalidLinesCount += 1
            }
        }
        
        if invalidLinesCount > 0 {
            let trimmedContent = keptLines.joined(separator: "\n")
            try trimmedContent.write(to: fileURL, atomically: true, encoding: .utf8)
            onInternalLog?("Removed \(invalidLinesCount) invalid log entries")
        }
    }
    
    /// Trims log entries when file size exceeds the maximum allowed size.
    private func trimLogsByFileSize(fileURL: URL, maxSize: Int) throws {
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        
        guard let fileSize = attributes[.size] as? Int, fileSize > maxSize else {
            return
        }
        
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = trimDecoder.splitContent(content)
        
        let targetSize = Int(Double(maxSize) * 0.8)
        var currentSize = 0
        var keptLines: [String] = []
        
        for line in lines.reversed() {
            let lineSize = line.data(using: .utf8)?.count ?? 0
            if currentSize + lineSize <= targetSize {
                keptLines.insert(line, at: 0)
                currentSize += lineSize
            } else {
                break
            }
        }
        
        let trimmedContent = keptLines.joined(separator: "\n")
        try trimmedContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let removedCount = lines.count - keptLines.count
        onInternalLog?("Trimmed log file by size. Removed \(removedCount) entries")
    }
    
    /// Trims log entries older than the specified age.
    private func trimLogsByAge(fileURL: URL, maxAge: TimeInterval) throws {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = trimDecoder.splitContent(content)
        
        let cutoffDate = Date().addingTimeInterval(-maxAge)
        var keptLines: [String] = []
        var removedCount = 0
        
        for line in lines {
            do {
                guard let entity = try trimDecoder.decode(line) else {
                    continue
                }
                
                if let logDate = entity.date, logDate >= cutoffDate {
                    keptLines.append(line)
                } else {
                    removedCount += 1
                }
            }
            catch {
                continue
            }
        }
        
        let trimmedContent = keptLines.joined(separator: "\n")
        try trimmedContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        if removedCount > 0 {
            onInternalLog?("Trimmed log file by age. Removed \(removedCount) old entries")
        }
    }
}

extension FileDestination: TypeNameProtocol {}
