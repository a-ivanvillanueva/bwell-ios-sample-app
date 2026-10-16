//
//  AppContainer.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 14-10-2026.
//

import Foundation

@MainActor
final class AppContainer {
    private let keychain: KeychainService
    private let apiKeyStore: APIKeyStore
    private let sdkManager: BWellSDKManager
    private let userRepository: UserRepository

    var session: SessionRepository {
        sdkManager
    }

    init() {
        let keychain = KeychainService()
        let apiKeyService = APIKeyService(keychain: keychain)
        let sdkManager = BWellSDKManager(tokenStorage: KeychainTokenStorageAdapter(keychain: keychain),
                                         keychain: keychain,
                                         apiKeyStore: apiKeyService)

        self.keychain = keychain
        self.apiKeyStore = apiKeyService
        self.sdkManager = sdkManager
        self.userRepository = BWellUserRepository(sdkManager: sdkManager)
    }

    // MARK: - ViewModel Factories
    func makeLaunchViewModel() -> LaunchViewModel {
        LaunchViewModel(session: session, apiKeyStore: apiKeyStore)
    }

    func makeAuthenticationViewModel() -> AuthenticationViewModel {
        AuthenticationViewModel(session: session, apiKeyStore: apiKeyStore)
    }

    func makeSideMenuViewModel() -> SideMenuViewModel {
        SideMenuViewModel(session: session)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(session: session, userRepository: userRepository)
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(userRepository: userRepository)
    }

    func makeManageConnectionsViewModel() -> ManageConnectionsViewModel {
        ManageConnectionsViewModel(sdkManager: sdkManager)
    }

    func makeSearchConnectionsViewModel() -> SearchConnectionsViewModel {
        SearchConnectionsViewModel(sdkManager: sdkManager)
    }

    func makeHealthSummaryViewModel() -> HealthSummaryViewModel {
        HealthSummaryViewModel(sdkManager: sdkManager)
    }
}

#if DEBUG
extension AppContainer {
    static let preview = AppContainer() // used by #Preview blocks
}
#endif
