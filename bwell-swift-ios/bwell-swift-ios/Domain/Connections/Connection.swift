//
//  Connection.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import Foundation

enum ConnectionStatus: Equatable {
    case connected, disconnected, deleted, expired, accessEnded, error, unknown
}

struct Connection: Identifiable, Equatable {
    let id: String
    let name: String
    let status: ConnectionStatus
}

// A provider, clinic, or health system you can search for and connect to.
struct HealthResource: Identifiable, Equatable {
    let id: String
    let name: String
    let connectionId: String
}

enum ConnectionError: LocalizedError {
    case invalidRedirectURL

    var errorDescription: String? {
        switch self {
        case .invalidRedirectURL: "The connection link returned by the server is not valid."
        }
    }
}
