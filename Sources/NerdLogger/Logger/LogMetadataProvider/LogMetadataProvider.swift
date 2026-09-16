//
//  LogMetadataProvider.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

/// A provider that supplies common key-value metadata to be merged into every ``LogEntity`` processed by a destination.
///
/// Destinations that accept a `LogMetadataProvider` merge its `metadata` dictionary into each record's
/// `extraInfo` before encoding, giving callers a way to attach ambient context (for example, a user ID or
/// session token) without threading it through every log call site.
public protocol LogMetadataProvider {
    /// Key-value pairs to merge into each log record's `extraInfo`. Values from the record take precedence on conflict.
    var metadata: [String: String] { get set }
}
