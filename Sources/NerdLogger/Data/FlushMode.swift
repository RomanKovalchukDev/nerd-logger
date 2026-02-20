//
//  FlushMode.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 29.12.2025.
//

import Foundation

public enum FlushMode {
    case always
    case manual
    case periodic(TimeInterval)
}
