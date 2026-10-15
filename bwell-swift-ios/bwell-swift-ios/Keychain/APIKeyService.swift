//
//  APIKeyService.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 12/11/25.
//
import Foundation

final class APIKeyService: APIKeyStore {
    private let account = "bwell-api-key"
    private let legacyDefaultsKey: String = "bwell_api_key"
    private let keychain: KeychainService

    init(keychain: KeychainService) {
        self.keychain = keychain
    }

    func save(_ apiKey: String) {
        do {
            try keychain.save(token: apiKey, account: account)
        } catch {
            Log.keychain.error("Could not save API key: \(error.localizedDescription)")
        }

    }

    func getAPIKey() -> String? {
        migrateLegacyKeyIfNeeded()

        do {
            return try keychain.loadToken(account: account)
        } catch {
            Log.keychain.error("Could not read API key: \(error.localizedDescription)")
            return nil
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)

        do {
            try keychain.deleteToken(account: account)
        } catch {
            Log.keychain.error("Could not delete API key: \(error.localizedDescription)")
        }
    }

    // Moves a keey saved by an older build out of UserDefaults.
    private func migrateLegacyKeyIfNeeded() {
        guard let legacy = UserDefaults.standard.string(forKey: legacyDefaultsKey) else {
            return
        }

        save(legacy)
        UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)
    }
}
