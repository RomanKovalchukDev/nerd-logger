//
//  LogDestinationProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

import Foundation

public protocol LogDestinationProtocol {
    var id: String { get }
    
    var filters: [any LogFilterProtocol] { get set }
    var encoder: any LogEncoderProtocol { get }
    var metadataProvider: (any LogMetadataProvider)? { get set }
    
    func log(_ entity: LogEntity)
}
