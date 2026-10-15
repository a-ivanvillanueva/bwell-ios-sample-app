//
//  SessionState.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 11/11/25.
//
import Foundation

enum SessionState {
    case uninitialized, initializing, initialized
    case checkingSession, unauthenticated, authenticating, authenticated
    case failed(Error)
}

extension SessionState: Equatable {
    static func == (lhs: SessionState, rhs: SessionState) -> Bool {
        switch (lhs, rhs) {
        case (.uninitialized, .uninitialized), (.initializing, .initializing),
            (.initialized, .initialized), (.checkingSession, .checkingSession),
            (.unauthenticated, .unauthenticated), (.authenticating, .authenticating),
            (.authenticated, .authenticated):

            return true

        case (.failed(let left), .failed(let right)):
            let left = left as NSError, right = right as NSError

            return left.domain == right.domain && left.code == right.code

        default:
            return false
        }
    }
}

enum SessionError: LocalizedError {
    case notInitialized
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .notInitialized: "The session hasn't been started yet."
        case .invalidCredentials: "The provided credentials are invalid."
        }
    }
}
