//
//  HomeViewModel.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 11/11/25.
//
import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    private let userRepository: UserRepository
    private var cancellables = Set<AnyCancellable>()

    @Published var firstName: String = ""
    @Published var isLoading: Bool = true

    init(session: SessionRepository, userRepository: UserRepository) {
        self.userRepository = userRepository

        // Subscribe to state changes to know when it's safe to fetch data.
        session.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if case .authenticated = state {
                    self?.fetchUsername()
                }
            }
            .store(in: &cancellables)
    }

    private func fetchUsername() {
        guard firstName.isEmpty else {
            isLoading = false
            return
        }

        isLoading = true

        Task {
            do {
                let profile = try await userRepository.getProfile()
                firstName = profile?.firstGivenName ?? "User"
            } catch {
                Log.profile.error("Error fetching user profile: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
