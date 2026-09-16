//
//  BufferedLineReaderTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 06.07.2026.
//

import Testing
import Foundation
@testable import NerdLogger

@Suite("BufferedLineReader Tests")
struct BufferedLineReaderTests {

    // MARK: - Test Helpers

    private static func makeStream(from string: String) -> InputStream {
        let data = string.data(using: .utf8) ?? Data()
        let stream = InputStream(data: data)
        stream.open()
        return stream
    }

    private static func readAllLines(_ reader: BufferedLineReader) -> [String] {
        var lines: [String] = []
        while let line = reader.readLine() {
            lines.append(line)
        }
        return lines
    }

    // MARK: - Basic reading

    @Test("readLine returns each newline-separated line in order")
    func testReadLineReturnsEachNewlineSeparatedLineInOrder() {
        // Arrange
        let stream = Self.makeStream(from: "alpha\nbeta\ngamma\n")

        // Act
        let sut = BufferedLineReader(stream: stream)
        let lines = Self.readAllLines(sut)

        // Assert
        #expect(lines == ["alpha", "beta", "gamma"])
    }

    @Test("readLine returns trailing line without newline")
    func testReadLineReturnsTrailingLineWithoutNewline() {
        // Arrange
        let stream = Self.makeStream(from: "one\ntwo")

        // Act
        let sut = BufferedLineReader(stream: stream)
        let lines = Self.readAllLines(sut)

        // Assert
        #expect(lines == ["one", "two"])
    }

    @Test("readLine returns nil for empty stream")
    func testReadLineReturnsNilForEmptyStream() {
        // Arrange
        let stream = Self.makeStream(from: "")

        // Act
        let sut = BufferedLineReader(stream: stream)
        let first = sut.readLine()

        // Assert
        #expect(first == nil)
    }

    // MARK: - Edge cases

    @Test("readLine handles very small buffer that requires multiple reads")
    func testReadLineHandlesVerySmallBufferThatRequiresMultipleReads() {
        // Arrange
        let stream = Self.makeStream(from: "hello world\nlong line here\n")

        // Act
        let sut = BufferedLineReader(stream: stream, bufferSize: 4)
        let lines = Self.readAllLines(sut)

        // Assert
        #expect(lines == ["hello world", "long line here"])
    }

    @Test("readLine returns empty string between consecutive newlines")
    func testReadLineReturnsEmptyStringBetweenConsecutiveNewlines() {
        // Arrange
        let stream = Self.makeStream(from: "a\n\nb\n")

        // Act
        let sut = BufferedLineReader(stream: stream)
        let lines = Self.readAllLines(sut)

        // Assert
        #expect(lines == ["a", "", "b"])
    }
}
