//
//  LogClosureFilterTests.swift
//  NerdLogger
//
//  Created by Roman Kovalchuk on 06.07.2026.
//

import Testing
import Foundation
@testable import NerdLogger

@Suite("LogClosureFilter Tests")
struct LogClosureFilterTests {

    // MARK: - Test Helpers

    private static func makeEntity(
        level: LogLevel = .info,
        tag: String? = nil,
        message: String = "hello"
    ) -> LogEntity {
        LogEntity(
            logLevel: level,
            message: message,
            tag: tag,
            date: Date()
        )
    }

    // MARK: - Behavior

    @Test("shouldIgnoreLog delegates to closure returning true")
    func testShouldIgnoreLogDelegatesToClosureReturningTrue() {
        // Arrange
        let sut = LogClosureFilter(id: "always-drop") { _ in true }
        let entity = Self.makeEntity()

        // Act
        let result = sut.shouldIgnoreLog(entity)

        // Assert
        #expect(result == true)
    }

    @Test("shouldIgnoreLog delegates to closure returning false")
    func testShouldIgnoreLogDelegatesToClosureReturningFalse() {
        // Arrange
        let sut = LogClosureFilter(id: "always-keep") { _ in false }
        let entity = Self.makeEntity()

        // Act
        let result = sut.shouldIgnoreLog(entity)

        // Assert
        #expect(result == false)
    }

    @Test("shouldIgnoreLog closure inspects entity properties")
    func testShouldIgnoreLogClosureInspectsEntityProperties() {
        // Arrange
        let sut = LogClosureFilter(id: "network-only") { entity in
            entity.tag != "Network"
        }
        let networkEntity = Self.makeEntity(tag: "Network")
        let otherEntity = Self.makeEntity(tag: "Other")

        // Act
        let dropNetwork = sut.shouldIgnoreLog(networkEntity)
        let dropOther = sut.shouldIgnoreLog(otherEntity)

        // Assert
        #expect(dropNetwork == false)
        #expect(dropOther == true)
    }

    @Test("id property returns injected value")
    func testIdPropertyReturnsInjectedValue() {
        // Arrange
        let identifier = "custom-id"

        // Act
        let sut = LogClosureFilter(id: identifier) { _ in false }

        // Assert
        #expect(sut.id == identifier)
    }
}
