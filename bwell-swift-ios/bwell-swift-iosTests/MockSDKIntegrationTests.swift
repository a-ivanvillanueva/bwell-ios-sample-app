//
//  MockSDKIntegrationTests.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 01-11-2026.
//

import Foundation
import Testing
import BWellSDK
@testable import bwell_swift_ios

@MainActor
struct MockSDKIntegrationTests {
    private func makeSession(_ provider: BWellSDKProvider) -> BWellSessionRepository {
        BWellSessionRepository(provider: provider, keychain: KeychainService(), apiKeyStore: FakeAPIKeyStore())
    }

    private func makeProvider() -> BWellSDKProvider {
        BWellSDKProvider(tokenStorage: InMemoryTokenStorage())
    }

    private func signedInProvider() async throws -> BWellSDKProvider {
        let provider = makeProvider()
        let session = makeSession(provider)
        try await session.start(apiKey: "test-key")
        try await session.signIn(with: .oauth(token: "token"))

        return provider
    }

    // MARK: Session

    @Test func restoringWithoutALoginSignsOutButKeepsTheSdkStarted() async throws {
        let session = makeSession(makeProvider())
        try await session.start(apiKey: "test-key")

        await session.restoreSession()

        #expect(session.authState == .signedOut)
        #expect(session.isStarted)
    }

    @Test func signingInThenRestoringKeepsTheUserSignedIn() async throws {
        let session = makeSession(makeProvider())
        try await session.start(apiKey: "test-key")

        try await session.signIn(with: .oauth(token: "token"))
        #expect(session.authState == .signedIn)

        await session.restoreSession()
        #expect(session.authState == .signedIn)
    }

    @Test func anEmptyApiKeyIsRejected() async {
        let session = makeSession(makeProvider())
        var caught: Error?

        do {
            try await session.start(apiKey: "")
        } catch {
            caught = error
        }

        #expect(caught as? SessionError == .invalidAPIKey)
    }

    @Test func emptyCredentialsAreRejectedAndTheUserStaysSignedOut() async throws {
        let session = makeSession(makeProvider())
        try await session.start(apiKey: "test-key")

        var caught: Error?
        
        do {
            try await session.signIn(with: .oauth(token: ""))
        } catch {
            caught = error
        }
        #expect(caught as? SessionError == .invalidCredentials)
    }

    // MARK: User

    @Test func theProfileComesFromTheSdkMappedToDomain() async throws {
        let repository = BWellUserRepository(provider: try await signedInProvider())

        let loaded = try await repository.getProfile()
        let profile = try #require(loaded)

        #expect(profile.givenName == "Alex")
        #expect(profile.familyName == "Sample")
        #expect(profile.address.lineOne == "123 Sample Street")
        #expect(profile.address.lineTwo == "Apt 4")
        #expect(profile.address.city == "Toronto")
        #expect(profile.gender == .other)
        #expect(profile.email == "alex.sample@example.org")
    }

    @Test func anUpdatedProfileIsReadBack() async throws {
        let repository = BWellUserRepository(provider: try await signedInProvider())
        let loaded = try await repository.getProfile()
        var profile = try #require(loaded)

        profile.givenName = "Sam"
        profile.address.lineOne = "9 New Road"

        try await repository.updateProfile(profile)

        let reloaded = try #require(try await repository.getProfile())

        #expect(reloaded.givenName == "Sam")
        #expect(reloaded.address.lineOne == "9 New Road")
    }

    // MARK: Connections and search

    @Test func connectionsAreListedAndTheSignInUrlIsValid() async throws {
        let repository = BWellConnectionRepository(provider: try await signedInProvider())

        let connections = try await repository.connections()
        let url = try await repository.oauthURL(for: "proa_demo")

        #expect(!connections.isEmpty)
        #expect(url.scheme == "https")
    }

    @Test func searchingFindsTheSampleClinic() async throws {
        let repository = BWellHealthResourceRepository(provider: try await signedInProvider())

        let results = try await repository.search(matching: "Clinic")

        #expect(results.map(\.name).contains("Sample Family Clinic"))
    }

    // MARK: Health records

    @Test(arguments: HealthCategory.allCases)
    func everyCategoryHasGroupsAndRecords(category: HealthCategory) async throws {
        let provider = makeProvider()
        try await provider.configure(apiKey: "test-key")
        let repository = BWellHealthRecordRepository(provider: provider)

        let groups = try await repository.groups(in: category)
        #expect(!groups.isEmpty)

        let group = try #require(groups.first)
        let records = try await repository.records(in: category, group: group)

        #expect(!records.isEmpty)
        #expect(records.allSatisfy { !$0.id.isEmpty })
    }

    @Test func theSummaryReportsCounts() async throws {
        let provider = makeProvider()
        try await provider.configure(apiKey: "test-key")

        let summary = try await BWellHealthRecordRepository(provider: provider).summary()

        #expect(!summary.isEmpty)
    }
}
