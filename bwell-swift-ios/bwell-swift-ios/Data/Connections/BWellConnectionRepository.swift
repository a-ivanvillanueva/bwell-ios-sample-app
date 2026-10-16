//
//  BWellConnectoinRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import Foundation
import BWellSDK

@MainActor
final class BWellConnectionRepository: ConnectionRepository {
    private let sdkManager: BWellSDKManager

    init(sdkManager: BWellSDKManager) {
        self.sdkManager = sdkManager
    }

    func connections() async throws -> [Connection] {
        try await sdkManager.connection().getMemberConnections().map(Connection.init(sdk:))
    }
    
    func delete(_ connectionId: String) async throws {
        let request = BWell.DeleteConnectionRequest(connectionId: connectionId)
        let result = try await sdkManager.connection().deleteConnection(request)

        Log.connections.debug("Delete connection - status: \(String(describing: result.statusUpdated))")
    }
    
    func disconnect(_ connectionId: String) async throws {
        let request = BWell.DisconnectConnectionRequest(connectionId: connectionId)
        let result = try await sdkManager.connection().disconnectConnection(request)

        Log.connections.debug("Disconnect connection - status: \(String(describing: result.status)), updated: \(result.statusUpdated)")

    }
    
    func oauthURL(for connectionId: String) async throws -> URL {
        let request = BWell.OAuthURLRequest(connectionId: connectionId)
        let result = try await sdkManager.connection().getOAuthURL(request)

        guard let url = URL(string: result.redirectURL) else {
            throw ConnectionError.invalidRedirectURL
        }

        return url
    }
}
