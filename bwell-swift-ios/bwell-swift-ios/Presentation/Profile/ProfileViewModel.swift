//
//  ProfileViewModel.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 29/10/25.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    private let userRepository: UserRepository

    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    // User's name
    @Published var givenName: String = ""
    @Published var familyName: String = ""

    // User's address
    @Published var addressLineOne: String = ""
    @Published var addressLineTwo: String = ""
    @Published var country: String = ""
    @Published var postalCode: String = ""
    @Published var state: String = ""
    @Published var city: String = ""

    // Other user's information
    @Published var gender: Gender = .unknown
    @Published var birthdate: String = ""
    @Published var language: String = ""
    @Published var email: String = ""
    @Published var workPhone: String = ""
    @Published var homePhone: String = ""
    @Published var mobilePhone: String = ""

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func getUserProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let profile = try await userRepository.getProfile() else { return }
            apply(profile)
        } catch {
            Log.profile.error("Failed retrieving profile: \(error.localizedDescription)")
            errorMessage = "We couldn't load your profile. Please try again."
        }
    }

    func updateUserProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await userRepository.updateProfile(makeProfile())
        } catch {
            Log.profile.error("Failed updating profile: \(error.localizedDescription)")
            errorMessage = "We couldn't save you profile. Please try again."
        }
    }

    private func apply(_ profile: UserProfile) {
        givenName = profile.givenName
        familyName = profile.familyName
        gender = profile.gender
        birthdate = profile.birthdate
        language = profile.language
        email = profile.email
        workPhone = profile.workphone
        homePhone = profile.homePhone
        addressLineOne = profile.address.lineOne
        addressLineTwo = profile.address.lineTwo
        city = profile.address.city
        state = profile.address.state
        postalCode = profile.address.postalCode
        country = profile.address.country

    }

    private func makeProfile() -> UserProfile {

        let address = Address(lineOne: addressLineOne,
                              lineTwo: addressLineTwo,
                              city: city,
                              state: state,
                              postalCode: postalCode,
                              country: country)

        let userProfile = UserProfile(givenName: givenName,
                    familyName: familyName,
                    gender: gender,
                    birthdate: birthdate,
                    language: language,
                    email: email,
                    workphone: workPhone,
                    homePhone: homePhone,
                    mobilePhone: mobilePhone,
                    address: address)

        return userProfile
    }
}
