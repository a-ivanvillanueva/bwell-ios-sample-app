//
//  TestSupport.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 27-10-2026.
//

import Foundation
import Combine
import BWellSDK
@testable import bwell_swift_ios

struct TestError: Error {}

/// Polls until the condition is true (or the timeout passes). View models start work in a Task,
/// so tests wait for the visible result instead of guessing a delay.
@MainActor
func waitUntil(timeout: Duration = .seconds(2), _ condition: () -> Bool) async {
    let deadline = ContinuousClock.now.advanced(by: timeout)
    while !condition() && ContinuousClock.now < deadline {
        try? await Task.sleep(for: .milliseconds(10))
    }
}

// MARK: - Fakes

@MainActor
final class FakeSessionRepository: SessionRepository {
    private let subject = CurrentValueSubject<AuthState, Never>(.signedOut)

    var authState: AuthState { subject.value }
    var authStatePublisher: AnyPublisher<AuthState, Never> {
        subject.removeDuplicates().eraseToAnyPublisher()
    }
    var isStarted = false

    var startError: Error?
    var signInError: Error?
    private(set) var startedWith: [String] = []
    private(set) var signInCount = 0

    func start(apiKey: String) async throws {
        startedWith.append(apiKey)
        if let startError { throw startError }
        isStarted = true
    }

    func restoreSession() async {}

    func signIn(with credentials: Credentials) async throws {
        signInCount += 1
        if let signInError { throw signInError }
        subject.send(.signedIn)
    }

    func signOut() {
        isStarted = false
        subject.send(.signedOut)
    }

    func simulate(_ state: AuthState) {
        subject.send(state)
    }
}

final class FakeAPIKeyStore: APIKeyStore {
    var storedKey: String?

    func save(_ apiKey: String) { storedKey = apiKey }
    func getAPIKey() -> String? { storedKey }
    func clear() { storedKey = nil }
}

@MainActor
final class FakeUserRepository: UserRepository {
    var profile: UserProfile?
    var error: Error?
    private(set) var updatedProfile: UserProfile?

    func getProfile() async throws -> UserProfile? {
        if let error { throw error }
        return profile
    }

    func updateProfile(_ profile: UserProfile) async throws {
        if let error { throw error }
        updatedProfile = profile
    }
}

@MainActor
final class FakeConnectionRepository: ConnectionRepository {
    var stored: [Connection] = []
    var error: Error?
    var url = URL(string: "https://example.org/oauth")!
    private(set) var deletedIds: [String] = []

    func connections() async throws -> [Connection] {
        if let error { throw error }
        return stored
    }

    func delete(_ connectionId: String) async throws {
        if let error { throw error }
        deletedIds.append(connectionId)
        stored.removeAll { $0.id == connectionId }
    }

    func disconnect(_ connectionId: String) async throws {
        if let error { throw error }
        stored = stored.map {
            $0.id == connectionId ? Connection(id: $0.id, name: $0.name, status: .disconnected) : $0
        }
    }

    func oauthURL(for connectionId: String) async throws -> URL {
        if let error { throw error }
        return url
    }
}

@MainActor
final class FakeHealthResourceRepository: HealthResourceRepository {
    var results: [HealthResource] = []
    var error: Error?

    func search(matching text: String?) async throws -> [HealthResource] {
        if let error { throw error }
        return results
    }
}

final class InMemoryTokenStorage: BWell.TokenStorage {
    private var values: [String: String] = [:]

    func get(key: String) -> String? { values[key] }
    func get(key: String, completion: @escaping (String?) -> Void) { completion(values[key]) }

    func getMany(keys: [String]) -> [String: String?] {
        var result: [String: String?] = [:]
        for key in keys { result[key] = .some(values[key]) }
        return result
    }

    func set(key: String, value: String) { values[key] = value }
    func setMany(keyValues: [String: String]) { values.merge(keyValues) { _, new in new } }
    func delete(key: String) -> Bool { values.removeValue(forKey: key) != nil }
}
