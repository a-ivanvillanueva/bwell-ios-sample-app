//
//  AuthenticationViewModelTests.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 01-11-2026.
//

import Foundation
import Testing
@testable import bwell_swift_ios

@MainActor
struct AuthenticationViewModelTests {
    private func makeSUT(isStarted: Bool = false)
        -> (viewModel: AuthenticationViewModel, session: FakeSessionRepository, store: FakeAPIKeyStore) {
        let session = FakeSessionRepository()
        session.isStarted = isStarted
        let store = FakeAPIKeyStore()
        return (AuthenticationViewModel(session: session, apiKeyStore: store), session, store)
    }

    @Test func showsTheApiKeyScreenWhenTheSdkIsNotStarted() {
        let sut = makeSUT()
        #expect(!sut.viewModel.apiKeyValidated)
    }

    @Test func showsTheLoginFormWhenTheSdkIsAlreadyStarted() {
        let sut = makeSUT(isStarted: true)
        #expect(sut.viewModel.apiKeyValidated)
    }

    @Test func rejectsAnEmptyApiKeyWithoutCallingTheSession() {
        let sut = makeSUT()

        sut.viewModel.initializeSDK()

        #expect(sut.viewModel.errorMessage == "API key is required.")
        #expect(sut.session.startedWith.isEmpty)
    }

    @Test func savesAValidApiKeyAndShowsTheLoginForm() async {
        let sut = makeSUT()
        sut.viewModel.apiKey = "my-key"

        sut.viewModel.initializeSDK()
        await waitUntil { !sut.viewModel.isLoading }

        #expect(sut.session.startedWith == ["my-key"])
        #expect(sut.store.storedKey == "my-key")
        #expect(sut.viewModel.apiKeyValidated)
        #expect(sut.viewModel.errorMessage == nil)
    }

    @Test func aRejectedApiKeyShowsAnErrorAndSavesNothing() async {
        let sut = makeSUT()
        sut.session.startError = TestError()
        sut.viewModel.apiKey = "bad-key"

        sut.viewModel.initializeSDK()
        await waitUntil { !sut.viewModel.isLoading }

        #expect(sut.viewModel.errorMessage != nil)
        #expect(!sut.viewModel.apiKeyValidated)
        #expect(sut.store.storedKey == nil)
    }

    @Test func emptyEmailAndPasswordShowFieldErrorsWithoutSigningIn() {
        let sut = makeSUT(isStarted: true)

        sut.viewModel.loginWithEmailAndPassword()

        #expect(sut.viewModel.emailErrorMessage == "Email is required.")
        #expect(sut.viewModel.passwordErrorMessage == "Password is required.")
        #expect(sut.session.signInCount == 0)
    }

    @Test func aFailedLoginShowsAMessageAndStopsLoading() async {
        let sut = makeSUT(isStarted: true)
        sut.session.signInError = TestError()
        sut.viewModel.email = "alex@example.org"
        sut.viewModel.password = "secret"

        sut.viewModel.loginWithEmailAndPassword()
        await waitUntil { !sut.viewModel.isLoading }

        #expect(sut.session.signInCount == 1)
        #expect(sut.viewModel.errorMessage != nil)
        #expect(!sut.viewModel.isLoading)
    }

    @Test func signingOutSendsTheUserBackToTheApiKeyScreen() async {
        let sut = makeSUT(isStarted: true)
        sut.session.simulate(.signedIn)
        #expect(sut.viewModel.apiKeyValidated)

        sut.session.signOut()   // also marks the SDK as no longer started
        await waitUntil { !sut.viewModel.apiKeyValidated }

        #expect(!sut.viewModel.apiKeyValidated)
    }
}
