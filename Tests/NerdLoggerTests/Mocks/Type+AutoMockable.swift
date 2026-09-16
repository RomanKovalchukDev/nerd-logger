//
//  Type+AutoMockable.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 31.12.2025.
//

@testable import NerdLogger

// sourcery: AutoMockable
extension LogProtocol {
}

// sourcery: AutoMockable
extension LogEncoderProtocol {
}

// sourcery: AutoMockable
extension LogDecoderProtocol {
}

// sourcery: AutoMockable
extension LogFetcherProtocol {
}

// sourcery: AutoMockable
extension LogMetadataProvider {
}

// NOTE: `LogFilterProtocol`, `LogDestinationProtocol`, and
// `PersistedLogDestinationProtocol` all inherit from ``TypeNameProtocol``, which
// declares both `static var typeName` and instance `var typeName`. Sourcery's
// current stencil emits both as instance properties, producing an invalid
// redeclaration in the generated mock. Existing tests avoid these mocks by
// exercising real destinations and filters, so we intentionally exclude them
// from AutoMockable until the shared stencil grows a `!static` guard.
