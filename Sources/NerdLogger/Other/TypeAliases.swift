//
//  TypeAliases.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation

/// A closure that receives diagnostic messages produced by the logging system itself.
///
/// Destinations and file managers accept an optional `InternalLog` to report internal errors
/// (setup failures, file rotation issues, dropped entries) without recursing into the log pipeline.
public typealias InternalLog = (String) -> Void

/// A predicate closure that decides whether a fetched ``LogEntity`` should be included in results.
public typealias LogFetcherFilter = (LogEntity) -> Bool
