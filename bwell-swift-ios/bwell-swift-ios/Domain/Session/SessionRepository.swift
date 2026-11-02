//
//  SessionRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 14-10-2026.
//

import Foundation
import Combine

@MainActor
protocol SessionRepository: AnyObject {
    var authState: AuthState { get }
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }

    /// True once the SDK has accepted an API key and is ready to use.
    var isStarted: Bool { get }

    /// Prepares the SDK with the API key. Throws if the key is rejected.
    func start(apiKey: String) async throws

    /// Checks whether a saved session is still valid and updates `authState`.
    func restoreSession() async

    func signIn(with credentials: Credentials) async throws
    func signOut()
}
