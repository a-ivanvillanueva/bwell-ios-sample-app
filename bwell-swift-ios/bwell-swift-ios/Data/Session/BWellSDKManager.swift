//
//  BWellSDKManager.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 27/10/25.
//
import Foundation
import Combine
import BWellSDK

@MainActor
final class BWellSDKManager: ObservableObject {
    private var sdk: BWellSDK?
    private let tokenStorage: any BWell.TokenStorage
    private let keychain: KeychainService
    private let apiKeyStore: APIKeyStore

    @Published private(set) var state: SessionState = .uninitialized

    init(tokenStorage: any BWell.TokenStorage, keychain: KeychainService, apiKeyStore: APIKeyStore) {
        self.tokenStorage = tokenStorage
        self.keychain = keychain
        self.apiKeyStore = apiKeyStore
    }

    /**
     * Initialized the BWell SDK with the provided client key.
     *
     * - Throws:
     *    - An error if the SDK fails to initialize.
     */
    func initialize(_ apiKey: String) async throws {
        if sdk != nil {
            Log.sdk.debug("SDK instance already exists.")
            return
        }

        self.state = .initializing
        do {
            let tokenStorage = KeychainTokenStorageAdapter(keychain: keychain)
            let config = BWell.SDKConfig(clientKey: apiKey, logLevel: .verbose,tokenStorage: tokenStorage)
            let sdkInstance = try BWellSDK(config: config)

            try await sdkInstance.initialize()
            self.sdk = sdkInstance
            self.state = .initialized

            Log.sdk.info("BWell SDK initialized successfully.")
        } catch {
            Log.sdk.error("Error initializing SDK: \(error.localizedDescription)")
            self.state = .failed(error)
            throw error
        }
    }

    /**
     * Checks if the SDK has an active session by attempting to fetch the user profile.
     * If successful, the state is updated to `.authenticated`.
     */
    func checkSessionStatus() async throws {
        guard let sdk = sdk else {
            state = .unauthenticated
            throw SessionError.notInitialized
        }

        state = .checkingSession

        do {
            _ = try await sdk.user.getProfile()
            self.state = .authenticated

            Log.sdk.info("Active session found. User is already authenticated.")
        } catch {
            Log.sdk.info("No active session found or token expired. Proceeding to login.")
            self.state = .unauthenticated
            throw error
        }
    }

    func validateSession() async {
            let maxRetries = 3
            for attempt in 1...maxRetries {
                do {
                    try await checkSessionStatus()
                    return
                } catch {
                    if attempt < maxRetries {
                        try? await Task.sleep(for: .seconds(2))
                    }
                }
            }

            // If all retries have failed nuke the failed SDK instance and reset the state completely.
            self.sdk = nil
            self.state = .uninitialized
        }

    /**
     * Authenticates the user with the given credentials.
     * On success, the `state` property is set to `.ready`.
     *
     * - Throws:
     *    - An error is authentication fails.
     */
    func login(credentials: Credentials) async throws {
        guard let sdk = sdk else { throw SessionError.notInitialized }
        self.state = .authenticating

        let sdkCredentials: BWell.Credentials = switch credentials {
        case .emailPassword(let email, let password):
                .emailPassword(email: email, password: password)
        case .oauth(let token):
                .oauth(token: token)
        }

        do {
            try await sdk.authenticate(credentials: sdkCredentials)

            let request: BWell.CreateConsentRequest = .init(status: .active,
                                                            provision: .init(type: .permit),
                                                            category: .tos)
            _ = try await sdk.user.createConsent(request)
            self.state = .authenticated

            Log.sdk.info("Login flow complete. SDK is ready.")
        } catch {
            Log.sdk.error("Login flow failed: \(error.localizedDescription)")

            self.state = .failed(error)
            throw error
        }
    }

    /**
     * Logs out the user by invalidating the SDK session and clearing all local tokens
     * from the secure keychain storage.
     */
    func logout() {
        Task {
            do {
                try keychain.clear()
                apiKeyStore.clear()

                await MainActor.run {
                    self.sdk = nil
                    self.state = .uninitialized
                }
            } catch {
                await MainActor.run {
                    self.state = .failed(error)
                }
            }
        }
    }
}

// - MARK: Extensions

extension BWellSDKManager {
    func health() throws -> HealthDataManager {
        guard let healthManager = sdk?.health else {
            throw SessionError.notInitialized
        }

        return healthManager
    }

    func connection() throws -> ConnectionManager {
        guard let connectionManager = sdk?.connection else {
            throw SessionError.notInitialized
        }

        return connectionManager
    }

    func device() throws -> DeviceManager {
        guard let device = sdk?.device else {
            throw SessionError.notInitialized
        }

        return device
    }

    func search() throws -> SearchManager {
        guard let search = sdk?.search else {
            throw SessionError.notInitialized
        }

        return search
    }

    func user() throws -> UserManager {
        guard let user = sdk?.user else {
            throw SessionError.notInitialized
        }

        return user
    }
}

extension BWellSDKManager: SessionRepository {
    var statePublisher: AnyPublisher<SessionState, Never> {
        $state.eraseToAnyPublisher()
    }
}
