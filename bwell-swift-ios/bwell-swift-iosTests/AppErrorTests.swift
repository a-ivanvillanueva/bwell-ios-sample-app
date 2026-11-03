//
//  AppErrorTests.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 02-11-2026.
//

import Foundation
import Testing
@testable import bwell_swift_ios

struct AppErrorTests {
    @Test func networkProblemsMeanOffline() {
        #expect(AppError(URLError(.notConnectedToInternet)) == .offline)
        #expect(AppError(URLError(.timedOut)) == .offline)
    }

    @Test func otherUrlErrorsAreUnknown() {
        #expect(AppError(URLError(.badURL)) == .unknown)
    }

    @Test func sessionErrorsAreMapped() {
        #expect(AppError(SessionError.invalidAPIKey) == .invalidAPIKey)
        #expect(AppError(SessionError.invalidCredentials) == .invalidCredentials)
        #expect(AppError(SessionError.notInitialized) == .sessionExpired)
    }

    @Test func unknownFailuresAreUnknown() {
        #expect(AppError(TestError()) == .unknown)
    }

    @Test func theMessageNamesTheActionAndHowToRecover() {
        let message = userMessage(for: URLError(.notConnectedToInternet), whileTrying: "save your profile")

        #expect(message == "We couldn't save your profile. You appear to be offline. Check your connection and try again.")
    }
}
