//
//  UserProfile.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import Foundation

struct Address: Equatable {
    var lineOne = ""
    var lineTwo = ""
    var city = ""
    var state = ""
    var postalCode = ""
    var country = ""
}

struct UserProfile: Equatable {
    var givenName = ""
    var familyName = ""
    var gender: Gender = .unknown
    var birthdate = ""
    var language = ""
    var email = ""
    var workphone = ""
    var homePhone = ""
    var mobilePhone = ""
    var address = Address()

    // First word of the given name (e.g. "Mary" for "Mary Ann").
    var firstGivenName: String? {
        givenName.split(separator: " ").first.map(String.init)
    }
}
