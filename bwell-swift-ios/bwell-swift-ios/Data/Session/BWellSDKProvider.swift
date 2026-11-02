//
//  BWellSDKProvider.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 01-11-2026.
//

import Foundation
import BWellSDK

@MainActor
final class BWellSDKProvider {
    private var sdk: BWellSDK?
    private let tokenStorage: any BWell.TokenStorage

    init(tokenStorage: any BWell.TokenStorage) {
        self.tokenStorage = tokenStorage
    }

    var isConfigured: Bool { sdk != nil }

    func configure(apiKey: String) async throws {
        #if DEBUG
        let config = BWell.SDKConfig(clientKey: apiKey, logLevel: .verbose, tokenStorage: tokenStorage)
        #else
        let config = BWell.SDKConfig(clientKey: apiKey, logLevel: .error, tokenStorage: tokenStorage)
        #endif

        let instance = try BWellSDK(config: config)
        try await instance.initialize()
        sdk = instance
    }

    func reset() {
        sdk = nil
    }

    func current() throws -> BWellSDK {
        guard let sdk else { throw SessionError.notInitialized }
        return sdk
    }

    func health() throws -> HealthDataManager { try current().health }
    func connection() throws -> ConnectionManager { try current().connection }
    func search() throws -> SearchManager { try current().search }
    func user() throws -> UserManager { try current().user }
}
