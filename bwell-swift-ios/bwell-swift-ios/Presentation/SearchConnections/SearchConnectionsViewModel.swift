//
//  SearchConnectionsViewModel.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 07/11/25.
//
import Foundation

@MainActor
final class SearchConnectionsViewModel: ObservableObject {
    private let searchRepository: HealthResourceRepository
    private let connectionRepository: ConnectionRepository

    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var healthResources: [HealthResource] = []
    @Published var oauthURL: URL?

    init(searchRepository: HealthResourceRepository, connectionRepository: ConnectionRepository) {
        self.searchRepository = searchRepository
        self.connectionRepository = connectionRepository
    }

    func searchHealthResources(searchedText: String?) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            healthResources = try await searchRepository.search(matching: searchedText)
        } catch {
            Log.connections.error("Search failed: \(error.localizedDescription)")
            errorMessage = "We couldn't load the results. Please try again."
        }
    }

    // Asks for the sign-in page of the chosen resource; the view reacts to 'oauthURL'.
    func requestOAuthURL(for resource: HealthResource) async {
        errorMessage = nil

        do {
            oauthURL = try await connectionRepository.oauthURL(for: resource.connectionId)
        } catch {
            Log.connections.error("OAuth URL failed: \(error.localizedDescription)")
            errorMessage = "We couldn't start the connection. Please try again."
        }
    }
}
