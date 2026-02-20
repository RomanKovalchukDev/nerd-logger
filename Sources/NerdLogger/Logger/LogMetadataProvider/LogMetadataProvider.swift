//
//  LogMetadataProvider.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

// Object that passess common metadata to logger
public protocol LogMetadataProvider {
    var metadata: [String: String] { get set }
}
