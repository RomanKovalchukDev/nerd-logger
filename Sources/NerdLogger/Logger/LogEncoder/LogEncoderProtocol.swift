//
//  LogEncoderProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

public protocol LogEncoderProtocol {
    func encode(_ entity: LogEntity) throws -> String
}
