//
//  BufferedLineReader.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 04.03.2026.
//

import Foundation

final class BufferedLineReader {
    private let stream: InputStream
    private let bufferSize: Int
    private var buffer: [UInt8]
    private var remainder = ""
    private var isEOF = false
    
    init(stream: InputStream, bufferSize: Int = 8_192) {
        self.stream = stream
        self.bufferSize = bufferSize
        self.buffer = [UInt8](repeating: 0, count: bufferSize)
    }
    
    func readLine() -> String? {
        while true {
            // Check if we already have a complete line in the remainder
            if let newlineIndex = remainder.firstIndex(of: "\n") {
                let line = String(remainder[remainder.startIndex..<newlineIndex])
                remainder = String(remainder[remainder.index(after: newlineIndex)...])
                return line
            }
            
            // If EOF and we have leftover, return it
            if isEOF {
                if remainder.isEmpty {
                    return nil
                }
                let last = remainder
                remainder = ""
                return last
            }
            
            // Read more data from stream
            let bytesRead = stream.read(&buffer, maxLength: bufferSize)
            
            if bytesRead <= 0 {
                isEOF = true
                continue
            }
            
            guard let chunk = String(bytes: buffer[0..<bytesRead], encoding: .utf8) else {
                isEOF = true
                continue
            }
            
            remainder += chunk
        }
    }
}
