//
//  APIKeyStore.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 14-10-2026.
//

import Foundation

protocol APIKeyStore {
    func save(_ apiKey: String)
    func getAPIKey() -> String?
    func clear()
}
