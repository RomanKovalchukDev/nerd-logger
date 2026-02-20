//
//  FileLogFetcher.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation

public final class FileLogFetcher: LogFetcherProtocol {
    
    // MARK: - Properties(public)
    
    public var decoder: any LogDecoderProtocol
    
    // MARK: - Properties(private)
    
    private let fileURL: URL
    
    // MARK: - Life cycle
    
    public init(fileURL: URL, decoder: any LogDecoderProtocol) {
        self.fileURL = fileURL
        self.decoder = decoder
    }
    
    // MARK: - Methods(public)
    
    public func fetchLogs(with filter: LogFetcherFilter?) throws -> [LogEntity] {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = decoder.splitContent(content)
        
        var entities: [LogEntity] = []
        
        for line in lines {
            do {
                guard let entity = try decoder.decode(line) else {
                    continue
                }
                
                if let filter {
                    if filter(entity) {
                        entities.append(entity)
                    }
                }
                else {
                    entities.append(entity)
                }
            }
            catch {
                continue
            }
        }
        
        return entities
    }
}
