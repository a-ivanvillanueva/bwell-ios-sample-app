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

    var session: SessionRepository {
        sdkManager
    }

    init() {
        let keychain = KeychainService()
        let apiKeyService = APIKeyService(keychain: keychain)
        self.keychain = keychain
        self.apiKeyStore = apiKeyService
        self.sdkManager = BWellSDKManager(
            tokenStorage: KeychainTokenStorageAdapter(keychain: keychain),
            keychain: keychain,
            apiKeyStore: apiKeyService
        )
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

    // TODO: - Replace these with protocols since these will take the concrete manager.
    func makeHomeViewModel() -> HomeViewModel { HomeViewModel(session: session) }
    func makeProfileViewModel() -> ProfileViewModel { ProfileViewModel(session: session) }
    func makeManageConnectionsViewModel() -> ManageConnectionsViewModel { ManageConnectionsViewModel(session: session) }
    func makeSearchConnectionsViewModel() -> SearchConnectionsViewModel { SearchConnectionsViewModel(session: session) }
    func makeHealthSummaryViewModel() -> HealthSummaryViewModel { HealthSummaryViewModel(session: session) }
}

#if DEBUG
extension AppContainer {
    static let preview = AppContainer() // used by #Preview blocks
}
#endif
