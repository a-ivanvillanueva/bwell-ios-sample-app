//
//  BWellUserRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import Foundation

final class BWellUserRepository: UserRepository {
    private let provider: BWellSDKProvider

    init(provider: BWellSDKProvider) {
        self.provider = provider
    }

    func getProfile() async throws -> UserProfile? {
        guard let result = try await provider.user().getProfile() else {
            return nil
        }
        return UserProfile(sdk: result)
    }

    func updateProfile(_ profile: UserProfile) async throws {
        _ = try await provider.user().updateProfile(profile.sdkUpdateRequest)
    }
}
