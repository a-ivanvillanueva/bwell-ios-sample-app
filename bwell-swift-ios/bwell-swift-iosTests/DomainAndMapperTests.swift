//
//  DomainAndMapperTests.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 01-11-2026.
//

import Foundation
import Testing
import BWellSDK
@testable import bwell_swift_ios

struct DomainAndMapperTests {
    // MARK: Domain

    @Test func firstGivenNameIsTheFirstWord() {
        var profile = UserProfile()
        profile.givenName = "Mary Ann"
        #expect(profile.firstGivenName == "Mary")
    }

    @Test func firstGivenNameIsNilWithoutAName() {
        #expect(UserProfile().firstGivenName == nil)
    }

    @Test func genderSurvivesAConversionToTheSdkAndBack() {
        for gender in Gender.allCases {
            #expect(Gender(sdk: gender.sdk) == gender)
        }
    }

    // MARK: Mappers (SDK to Domain)

    @Test func anAddressWithoutLinesDoesNotCrash() {
        let result = BWell.GetUserProfileResult(address: [BWell.Address(line: [], city: "Toronto")])

        let profile = UserProfile(sdk: result)

        #expect(profile.address.lineOne.isEmpty)
        #expect(profile.address.lineTwo.isEmpty)
        #expect(profile.address.city == "Toronto")
    }

    @Test func twoAddressLinesFillBothFields() {
        let result = BWell.GetUserProfileResult(address: [BWell.Address(line: ["1 Main St", "Unit 2"])])

        let profile = UserProfile(sdk: result)

        #expect(profile.address.lineOne == "1 Main St")
        #expect(profile.address.lineTwo == "Unit 2")
    }

    @Test func contactsAreMappedByTheirUseField() {
        let result = BWell.GetUserProfileResult(
            name: [BWell.HumanName(family: "Sample", given: ["Mary", "Ann"])],
            gender: .female,
            telecom: [BWell.ContactPoint(use: "email", value: "a@example.org"),
                      BWell.ContactPoint(use: "mobile", value: "555-0100")])

        let profile = UserProfile(sdk: result)

        #expect(profile.givenName == "Mary Ann")
        #expect(profile.familyName == "Sample")
        #expect(profile.gender == .female)
        #expect(profile.email == "a@example.org")
        #expect(profile.mobilePhone == "555-0100")
    }

    @Test func theUpdateRequestSplitsTheGivenNameIntoWords() {
        var profile = UserProfile()
        profile.givenName = "Mary Ann"
        profile.familyName = "Sample"
        profile.gender = .female
        profile.address.lineOne = "1 Main St"
        profile.address.lineTwo = "Unit 2"

        let request = profile.sdkUpdateRequest

        #expect(request.name?.given == ["Mary", "Ann"])
        #expect(request.name?.family == "Sample")
        #expect(request.addressStreet == "1 Main St")
        #expect(request.addressUnit == "Unit 2")
        #expect(request.gender == .female)
    }
}
