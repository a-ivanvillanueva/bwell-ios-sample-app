//
//  HomeViewModel.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 11/11/25.
//
import Foundation
import BWellSDK
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    private var sdkManager: BWellSDKManager?
    private let session: SessionRepository
    private var cancellables = Set<AnyCancellable>()

    @Published var firstName: String = ""
    @Published var isLoading: Bool = true

    init(session: SessionRepository) {
        self.session = session

        // Subscribe to state changes to know when it's safe to fetch data.
        sdkManager?.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if case .authenticated = state {
                    self?.fetchUsername()
                }
            }
            .store(in: &cancellables)

        if case .authenticated = sdkManager?.state {
            fetchUsername()
        }
    }

    private func fetchUsername() {
        guard firstName.isEmpty else {
            isLoading = false
            return
        }

        isLoading = true

        Task {
            do {
                let user = try await sdkManager?.user().getProfile()
                self.firstName = user?.name?.first?.given?.first ?? "User"
            } catch {
                Log.profile.error("Error fetching user profile: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
