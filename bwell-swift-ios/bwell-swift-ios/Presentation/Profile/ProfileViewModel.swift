//
//  ProfileViewModel.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 29/10/25.
//

import Foundation
import BWellSDK

@MainActor
final class ProfileViewModel: ObservableObject {
    private var sdkManager: BWellSDKManager?
    private let session: SessionRepository
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
    @Published var gender: BWell.Gender = .male
    @Published var birthdate: String = ""
    @Published var language: String = ""
    @Published var email: String = ""
    @Published var workPhone: String = ""
    @Published var homePhone: String = ""
    @Published var mobilePhone: String = ""

    init(session: SessionRepository) {
        self.session = session
    }

    func getUserProfile() async {
        isLoading = true
        do {
            guard let sdkManager = sdkManager else {
                errorMessage = "SDK Manager not available"
                isLoading = false
                return
            }

            guard let profileInformation = try await sdkManager.user().getProfile() else {
                isLoading = false
                return
            }

            parseData(data: profileInformation)
            isLoading = false
        } catch {
            Log.profile.error("Failed retrieving profile: \(error.localizedDescription)")
            isLoading = false
        }
    }

    func updateUserProfile() async {
        isLoading = true
        do {
            guard let sdkManager = sdkManager else {
                errorMessage = "SDK Manager not available"
                isLoading = false
                return
            }

            let given: [String] = givenName.components(separatedBy: " ")

            let userName: BWell.HumanName = .init(family: familyName, given: given)

            let updateProfileRequest: BWell.UpdateUserProfileRequest = .init(name: userName,
                                                                             addressStreet: addressLineOne,
                                                                             addressUnit: addressLineTwo,
                                                                             city: city,
                                                                             stateOrProvidence: state,
                                                                             postageOrZipCode: postalCode,
                                                                             birthDate: birthdate,
                                                                             gender: gender,
                                                                             language: language)

            _ = try await sdkManager.user().updateProfile(updateProfileRequest)

            isLoading = false
        } catch {
            Log.profile.error("Failed updating profile: \(error.localizedDescription)")
            errorMessage = "We couldn't save you profile. Please try again."
            isLoading = false
        }
    }

    private func parseData(data: BWell.GetUserProfileResult) {
        if let names = data.name {
            if let first = names.first {
                givenName = first.given?.joined(separator: " ") ?? ""
                familyName = first.family ?? ""
            }
        }

        if let address = data.address?.first {
            let lines = address.line ?? []
            addressLineOne = lines.first ?? ""
            addressLineTwo = lines.dropFirst().first ?? ""
            country = address.country ?? ""
            state = address.state ?? ""
            postalCode = address.postalCode ?? ""
            city = address.city ?? ""
        }

        if let gender = data.gender {
            self.gender = gender
        }

        if let birthdate = data.birthdate {
            self.birthdate = birthdate
        }

        if let language = data.language {
            self.language = language
        }

        if let telecom = data.telecom {
            for contactPoint in telecom {
                if contactPoint.use == "email" {
                    email = contactPoint.value ?? ""
                } else if contactPoint.use == "mobile" {
                    mobilePhone = contactPoint.value ?? ""
                } else if contactPoint.use == "work" {
                    workPhone = contactPoint.value ?? ""
                } else if contactPoint.use == "home" {
                    homePhone = contactPoint.value ?? ""
                }
            }
        }
    }
}
