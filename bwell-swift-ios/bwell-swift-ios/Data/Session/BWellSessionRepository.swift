//
//  BWellSessionRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 01-11-2026.
//

import Foundation
import Combine
import BWellSDK

@MainActor
final class BWellSessionRepository: SessionRepository {
    private let provider: BWellSDKProvider
    private let keychain: KeychainService
    private let apiKeyStore: APIKeyStore
    private let authStateSubject = CurrentValueSubject<AuthState, Never>(.signedOut)

    init(provider: BWellSDKProvider, keychain: KeychainService, apiKeyStore: APIKeyStore) {
        self.provider = provider
        self.keychain = keychain
        self.apiKeyStore = apiKeyStore
    }

    var authState: AuthState { authStateSubject.value }

    var authStatePublisher: AnyPublisher<AuthState, Never> {
        authStateSubject.removeDuplicates().eraseToAnyPublisher()
    }

    var isStarted: Bool { provider.isConfigured }

    func start(apiKey: String) async throws {
        guard !provider.isConfigured else { return }

        do {
            try await provider.configure(apiKey: apiKey)
            Log.sdk.info("BWell SDK started.")
        } catch let error as URLError where error.isOffline {
            throw error
        } catch {
            Log.sdk.error("Could not start SDK: \(error.localizedDescription)")
            throw SessionError.invalidAPIKey
        }
    }

    func restoreSession() async {
        let maxAttempts = 3

        for attempt in 1...maxAttempts {
            do {
                _ = try await provider.user().getProfile()
                authStateSubject.send(.signedIn)
                Log.sdk.info("Active session found.")
                return
            } catch {
                // Only wait and retry when the network might come back.
                guard attempt < maxAttempts, Self.isTemporary(error) else { break }
                try? await Task.sleep(for: .seconds(2))
            }
        }

        // The SDK stays started, so the user only needs to log in, not re-enter the API key.
        Log.sdk.info("No active session. Login required.")
        authStateSubject.send(.signedOut)
    }

    func signIn(with credentials: Credentials) async throws {
        let sdk = try provider.current()

        do {
            try await sdk.authenticate(credentials: credentials.sdk)

            // The sample accepts the terms of service automatically at login.
            let request: BWell.CreateConsentRequest = .init(status: .active,
                                                            provision: .init(type: .permit),
                                                            category: .tos)
            _ = try await sdk.user.createConsent(request)

            authStateSubject.send(.signedIn)
            Log.sdk.info("Login flow complete.")
        }  catch let error as URLError where error.isOffline {
            throw error
        } catch {
            Log.sdk.error("Login flow failed: \(error.localizedDescription)")
            throw SessionError.invalidCredentials
        }
    }

    func signOut() {
        do {
            try keychain.clear()
        } catch {
            // Still sign out in the app, but leave a trace of the failure.
            Log.keychain.error("Could not clear Keychain on sign out: \(error.localizedDescription)")
        }
        apiKeyStore.clear()
        provider.reset()
        authStateSubject.send(.signedOut)
    }

    private static func isTemporary(_ error: Error) -> Bool {
        (error as? URLError)?.isOffline ?? false
    }
}

private extension Credentials {
    var sdk: BWell.Credentials {
        switch self {
        case .emailPassword(let email, let password): .emailPassword(email: email, password: password)
        case .oauth(let token): .oauth(token: token)
        }
    }
}
