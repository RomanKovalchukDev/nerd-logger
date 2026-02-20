//
//  LogFetcherProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

public protocol LogFetcherProtocol {
    var decoder: any LogDecoderProtocol { get set }
    
    func fetchLogs(with filter: LogFetcherFilter?) throws -> [LogEntity]
}
