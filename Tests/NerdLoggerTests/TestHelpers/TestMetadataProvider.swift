//
//  TestMetadataProvider.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 08.01.2026.
//

import Foundation
@testable import NerdLogger

struct TestMetadataProvider: LogMetadataProvider {
    var metadata: [String: String] = [:]
}
