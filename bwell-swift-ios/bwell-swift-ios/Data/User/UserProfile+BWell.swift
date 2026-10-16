//
//  UserProfile+BWell.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import Foundation
import BWellSDK

extension UserProfile {
    init(sdk result: BWell.GetUserProfileResult) {
        self.init()

        if let name = result.name?.first {
            givenName = name.given?.joined(separator: " ") ?? ""
            familyName = name.family ?? ""
        }

        if let sdkAddress = result.address?.first {
            let addressLines = sdkAddress.line ?? []

            address = Address(lineOne: addressLines.first ?? "",
                              lineTwo: addressLines.dropFirst().first ?? "",
                              city: sdkAddress.city ?? "",
                              state: sdkAddress.state ?? "",
                              postalCode: sdkAddress.postalCode ?? "",
                              country: sdkAddress.country ?? "")
        }

        gender = result.gender.map(Gender.init(sdk:)) ?? .unknown
        birthdate = result.birthdate ?? ""
        language = result.language ?? ""

        for contact in result.telecom ?? [] {
            switch contact.use {
            case "email": email = contact.value ?? ""
            case "mobile": mobilePhone = contact.value ?? ""
            case "work": workphone = contact.value ?? ""
            case "home": homePhone = contact.value ?? ""
            default: break
            }
        }
    }

    var sdkUpdateRequest: BWell.UpdateUserProfileRequest {
        BWell.UpdateUserProfileRequest(
            name: BWell.HumanName(family: familyName, given: givenName.components(separatedBy: " ")),
            addressStreet: address.lineOne,
            addressUnit: address.lineTwo,
            city: address.city,
            stateOrProvidence: address.state,
            postageOrZipCode: address.postalCode,
            birthDate: birthdate,
            gender: gender.sdk,
            language: language
        )
    }
}

extension Gender {
    init(sdk: BWell.Gender) {
        switch sdk {
        case .female: self = .female
        case .male: self = .male
        case .other: self = .other
        case .unknown: self = .unknown
        }
    }

    var sdk: BWell.Gender {
        switch self {
        case .female: .female
        case .male: .male
        case .other: .other
        case .unknown: .unknown
        }
    }
}
