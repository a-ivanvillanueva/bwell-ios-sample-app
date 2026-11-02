//
//  HomeAndProfileViewModelTests.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 01-11-2026.
//

import Foundation
import Testing
@testable import bwell_swift_ios

@MainActor
struct HomeViewModelTests {
    private func makeSUT(profile: UserProfile?) -> (HomeViewModel, FakeSessionRepository) {
        let session = FakeSessionRepository()
        let users = FakeUserRepository()
        users.profile = profile
        return (HomeViewModel(session: session, userRepository: users), session)
    }

    @Test func showsTheFirstGivenNameAfterSignIn() async {
        var profile = UserProfile()
        profile.givenName = "Mary Ann"
        let (viewModel, session) = makeSUT(profile: profile)

        session.simulate(.signedIn)
        await waitUntil { !viewModel.isLoading }

        #expect(viewModel.firstName == "Mary")
    }

    @Test func fallsBackToAGenericNameWhenThereIsNoProfile() async {
        let (viewModel, session) = makeSUT(profile: nil)

        session.simulate(.signedIn)
        await waitUntil { !viewModel.isLoading }

        #expect(viewModel.firstName == "User")
    }
}

@MainActor
struct ProfileViewModelTests {
    private func sampleProfile() -> UserProfile {
        UserProfile(givenName: "Alex", familyName: "Sample", gender: .other,
                    birthdate: "1990-01-01", language: "English",
                    email: "alex@example.org", workphone: "", homePhone: "",
                    mobilePhone: "555-0100",
                    address: Address(lineOne: "1 Main St", lineTwo: "Unit 2", city: "Toronto",
                                     state: "ON", postalCode: "M5V 0A0", country: "Canada"))
    }

    @Test func loadsTheProfileIntoTheFormFields() async {
        let users = FakeUserRepository()
        users.profile = sampleProfile()
        let viewModel = ProfileViewModel(userRepository: users)

        await viewModel.getUserProfile()

        #expect(viewModel.givenName == "Alex")
        #expect(viewModel.familyName == "Sample")
        #expect(viewModel.gender == .other)
        #expect(viewModel.email == "alex@example.org")
        #expect(viewModel.addressLineOne == "1 Main St")
        #expect(viewModel.addressLineTwo == "Unit 2")
        #expect(viewModel.city == "Toronto")
        #expect(!viewModel.isLoading)
    }

    @Test func aLoadFailureSetsAMessageAndStopsLoading() async {
        let users = FakeUserRepository()
        users.error = TestError()
        let viewModel = ProfileViewModel(userRepository: users)

        await viewModel.getUserProfile()

        #expect(viewModel.errorMessage != nil)
        #expect(!viewModel.isLoading)
    }

    @Test func savingSendsWhatTheFormContains() async {
        let users = FakeUserRepository()
        let viewModel = ProfileViewModel(userRepository: users)
        viewModel.givenName = "Sam"
        viewModel.addressLineOne = "9 New Road"
        viewModel.gender = .female

        await viewModel.updateUserProfile()

        #expect(users.updatedProfile?.givenName == "Sam")
        #expect(users.updatedProfile?.address.lineOne == "9 New Road")
        #expect(users.updatedProfile?.gender == .female)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func aSaveFailureSetsAMessage() async {
        let users = FakeUserRepository()
        users.error = TestError()
        let viewModel = ProfileViewModel(userRepository: users)

        await viewModel.updateUserProfile()

        #expect(viewModel.errorMessage != nil)
        #expect(!viewModel.isLoading)
    }
}
