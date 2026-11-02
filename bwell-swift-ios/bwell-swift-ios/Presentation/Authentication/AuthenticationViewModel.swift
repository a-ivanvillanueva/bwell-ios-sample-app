//
//  AuthenticationViewModel.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 31/10/25.
//

import Foundation
import Combine

@MainActor
final class AuthenticationViewModel: ObservableObject {
    private let session: SessionRepository
    private let apiKeyStore: APIKeyStore
    private var cancellables = Set<AnyCancellable>()

    // Authentication published properties
    @Published var apiKey: String = ""
    @Published var oauthToken: String = ""
    @Published var email: String = ""
    @Published var password: String = ""

    // Published properties
    @Published var isLoading: Bool = false
    @Published var apiKeyValidated: Bool = false

    @Published var emailErrorMessage: String? = nil
    @Published var passwordErrorMessage: String? = nil
    @Published var errorMessage: String? = nil

    init(session: SessionRepository, apiKeyStore: APIKeyStore) {
        self.session = session
        self.apiKeyStore = apiKeyStore
        self.apiKeyValidated = session.isStarted

        // Signing out, or a session that can't be restored, brings the user back to this screen.
        session.authStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self, state == .signedOut else { return }
                self.apiKeyValidated = self.session.isStarted
                self.isLoading = false
            }
            .store(in: &cancellables)
    }

    func initializeSDK() {
        guard !apiKey.isEmpty else {
            errorMessage = "API key is required."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                try await session.start(apiKey: apiKey)
                apiKeyStore.save(apiKey)
                apiKeyValidated = true
            } catch {
                errorMessage = "We couldn't start with that API key."
            }
        }
    }

    func loginWithOAuthToken() {
        guard !oauthToken.isEmpty else {
            errorMessage = "OAuth token is required."
            return
        }

        signIn(with: .oauth(token: oauthToken))
    }

    func loginWithEmailAndPassword() {
        emailErrorMessage = email.isEmpty ? "Email is required." : nil
        passwordErrorMessage = password.isEmpty ? "Password is required." : nil

        // Stop here if validation failed; don't call the SDK with empty credentials.
        guard emailErrorMessage == nil, passwordErrorMessage == nil else { return }

        signIn(with: .emailPassword(email: email, password: password))
    }

    private func signIn(with credentials: Credentials) {
        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                try await session.signIn(with: credentials)
            } catch {
                errorMessage = "Login failed. Please check your details and try again."
            }
        }
    }
}
