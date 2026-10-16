//
//  ManageConnectionsViewModel.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 31/10/25.
//
import Foundation

@MainActor
final class ManageConnectionsViewModel: ObservableObject {
    private let repository: ConnectionRepository

    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var memberConnections: [Connection] = []

    init(repository: ConnectionRepository) {
        self.repository = repository
    }

    func getConnections() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            memberConnections = try await repository.connections()
            Log.connections.debug("Loaded \(self.memberConnections.count) member connections")
        } catch {
            Log.connections.error("Failed to load connections: \(error.localizedDescription)")
            errorMessage = "We couldn't load your connections. Please try again."
        }
    }

    /// Deletes a connection and refreshes the connections list
    /// - Parameter connectionId: The ID of the connection to delete
    func deleteConnection(connectionId: String) async {
        await perform(failureMesssage: "We couldn't delete the connection.") {
            try await repository.delete(connectionId)
        }
    }

    /// Disconnects a connection and refreshes the connections list
    /// - Parameter connectionId: The ID of the connection to disconnect
    func disconnectConnection(connectionId: String) async {
        await perform(failureMesssage: "We couldn't disconnect the connection.") {
            try await repository.disconnect(connectionId)
        }
    }

    private func perform(failureMesssage: String, _ action: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil

        do {
            try await action()
            await getConnections()
        } catch {
            Log.connections.error("\(failureMesssage) \(error.localizedDescription)")
            errorMessage = failureMesssage
            isLoading = false
        }
    }

    /*webfunc getOAuthURL(search userRequest: String) async {
        do {
            guard let sdkManager = sdkManager else {
                errorMessage = "SDK Manager not available"
                isLoading = false
                return
            }

            let request = BWell.OAuthURLRequest(connectionId: userRequest)
            let response = try await sdkManager.connection().getOAuthURL(request)

            url = URL(string: response.redirectURL)
        } catch {
            errorMessage = "Failed to established a connection."
            return
        }
    }*/
}
