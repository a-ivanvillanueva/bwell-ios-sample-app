//
//  SessionError.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 11/11/25.
//
import Foundation

enum SessionError: LocalizedError {
    case notInitialized
    case invalidAPIKey
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .notInitialized: "The session hasn't been started yet."
        case .invalidAPIKey: "The API Key was not accepted."
        case .invalidCredentials: "The provided credentials are invalid."
        }
    }
}
