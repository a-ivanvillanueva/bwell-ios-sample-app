//
//  UserRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import Foundation

@MainActor
protocol UserRepository {
    func getProfile() async throws -> UserProfile?
    func updateProfile(_ profile: UserProfile) async throws
}
