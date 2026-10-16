//
//  BWellUserRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import Foundation

final class BWellUserRepository: UserRepository {
    private let sdkManager: BWellSDKManager

    init(sdkManager: BWellSDKManager) {
        self.sdkManager = sdkManager
    }

    func getProfile() async throws -> UserProfile? {
        guard let result = try await sdkManager.user().getProfile() else {
            return nil
        }
        return UserProfile(sdk: result)
    }

    func updateProfile(_ profile: UserProfile) async throws {
        _ = try await sdkManager.user().updateProfile(profile.sdkUpdateRequest)
    }
}
