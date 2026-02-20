//
//  PersistedLogDestinationProtocol.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 07.01.2026.
//

public protocol PersistedLogDestinationProtocol: LogDestinationProtocol {
    func setup()
    func flush()
}
