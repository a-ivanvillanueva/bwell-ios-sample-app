//
//  AppError.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 02-11-2026.
//

import Foundation

/// The types of failure a user can do something about.
/// Anything else is reported as `.unknown`,  the details go to the log.
enum AppError: LocalizedError, Equatable {
    case offline
    case invalidAPIKey
    case invalidCredentials
    case sessionExpired
    case invalidResponse
    case unknown

    init(_ error: Error) {
        switch error {
        case let error as AppError:
            self = error
        case let error as SessionError:
            switch error {
            case .notInitialized: self = .sessionExpired
            case .invalidAPIKey: self = .invalidAPIKey
            case .invalidCredentials: self = .invalidCredentials
            }
        case is ConnectionError:
            self = .invalidResponse
        case let error as URLError where error.isOffline:
            self = .offline
        default:
            self = .unknown
        }
    }

    var errorDescription: String? {
        switch self {
        case .offline: "You appear to be offline."
        case .invalidAPIKey: "That API key wasn't accepted."
        case .invalidCredentials: "invalid email and/or password."
        case .sessionExpired: "Your session has ended."
        case .invalidResponse: "The server sent a response we couldn't read."
        case .unknown: "Something went wrong."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .offline: "Check your connection and try again."
        case .invalidAPIKey: "Check the key and try again."
        case .invalidCredentials: "Check your details and try again."
        case .sessionExpired: "Please sign in again."
        case .invalidResponse, .unknown: "Please try again."
        }
    }
}

extension URLError {
    var isOffline: Bool {
        switch code {
        case .notConnectedToInternet, .timedOut, .networkConnectionLost,
             .cannotConnectToHost, .dnsLookupFailed:
            true
        default:
            false
        }
    }
}
