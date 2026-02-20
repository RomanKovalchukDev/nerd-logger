//
//  DispatchQueue+CurrentLabel.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 19.06.2025.
//

import Foundation

extension DispatchQueue {
    class var currentLabel: String {
        String(validatingUTF8: __dispatch_queue_get_label(nil)) ?? ""
    }
}
