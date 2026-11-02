//
//  AppContainer.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 14-10-2026.
//

import Foundation

@MainActor
final class AppContainer {
    private let apiKeyStore: APIKeyStore
    private let userRepository: UserRepository
    private let connectionRepository: ConnectionRepository
    private let healthResourceRepository: HealthResourceRepository
    private let healthRecordRepository: HealthRecordRepository

    let session: SessionRepository

    init() {
        let keychain = KeychainService()
        let apiKeyService = APIKeyService(keychain: keychain)
        let provider = BWellSDKProvider(tokenStorage: KeychainTokenStorageAdapter(keychain: keychain))

        self.apiKeyStore = apiKeyService
        self.session = BWellSessionRepository(provider: provider,
                                              keychain: keychain,
                                              apiKeyStore: apiKeyService)
        self.userRepository = BWellUserRepository(provider: provider)
        self.connectionRepository = BWellConnectionRepository(provider: provider)
        self.healthResourceRepository = BWellHealthResourceRepository(provider: provider)
        self.healthRecordRepository = BWellHealthRecordRepository(provider: provider)
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
        ManageConnectionsViewModel(repository: connectionRepository)
    }

    func makeSearchConnectionsViewModel() -> SearchConnectionsViewModel {
        SearchConnectionsViewModel(searchRepository: healthResourceRepository, connectionRepository: connectionRepository)
    }

    func makeHealthSummaryViewModel() -> LoadableViewModel<[HealthCategory: Int]> {
        let repository = healthRecordRepository
        return LoadableViewModel(initialValue: [:]) { try await repository.summary() }
    }

    func makeHealthGroupsViewModel(for category: HealthCategory) -> LoadableViewModel<[HealthGroup]> {
        let repository = healthRecordRepository
        return LoadableViewModel(initialValue: []) { try await repository.groups(in: category) }
    }

    func makeHealthRecordsViewModel(for category: HealthCategory,
                                    group: HealthGroup) -> LoadableViewModel<[HealthRecord]> {
        let repository = healthRecordRepository
        return LoadableViewModel(initialValue: []) {
            try await repository.records(in: category, group: group)
        }
    }
}

#if DEBUG
extension AppContainer {
    static let preview = AppContainer() // used by #Preview blocks
}
#endif
