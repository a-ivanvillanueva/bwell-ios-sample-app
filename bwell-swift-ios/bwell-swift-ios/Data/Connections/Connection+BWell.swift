//
//  Connection+BWell.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import BWellSDK

extension ConnectionStatus {
    init(sdk: BWell.DataConnectionStatus) {
        switch sdk {
        case .connected: self = .connected
        case .disconnected: self = .disconnected
        case .deleted: self = .deleted
        case .expired: self = .expired
        case .accessEnded: self = .accessEnded
        case .error: self = .error
        case .unknown: self = .unknown
        }
    }
}

extension Connection {
    init(sdk: BWell.MemberConnectionResult) {
        self.init(id: sdk.id, name: sdk.name, status: ConnectionStatus(sdk: sdk.status))
    }
}

extension HealthResource {
    // Returns nil for results without a name, so the UI never has to check.
    init?(sdk result: BWell.SearchHealthResourcesResults.Result) {
        guard let name = result.content, !name.isEmpty else {
            return nil
        }

        // THe demo SDK uses "proa_demo" when a result has no endpoint.
        let connectionId = result.endpoint?.first?.name ?? "proa_demo"
        self.init(id: result.id ?? name, name: name, connectionId: connectionId)
    }
}
