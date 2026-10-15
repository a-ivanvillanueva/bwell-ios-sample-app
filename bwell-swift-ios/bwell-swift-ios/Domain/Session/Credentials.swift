//
//  Credentials.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 14-10-2026.
//

import Foundation

enum Credentials {
    case emailPassword(email: String, password: String)
    case oauth(token: String)
}
