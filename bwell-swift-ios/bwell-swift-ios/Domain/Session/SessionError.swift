//
//  SessionError.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 11/11/25.
//
import Foundation

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
