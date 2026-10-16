//
//  ConnectionStatus+Display.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 16-10-2026.
//

import Foundation

extension ConnectionStatus {
    var displayName: String {
        switch self {
        case .connected: "CONNECTED"
        case .disconnected: "DISCONNECTED"
        case .deleted: "DELETED"
        case .expired: "EXPIRED"
        case .accessEnded: "ACCESS ENDED"
        case .error: "ERROR"
        case .unknown: "UNKOWN"
        }
    }
}
