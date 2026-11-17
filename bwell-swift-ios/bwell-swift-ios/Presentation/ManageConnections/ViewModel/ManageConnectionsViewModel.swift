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
            errorMessage = userMessage(for: error, whileTrying: "load your connections")
        }
    }

    /// Deletes a connection and refreshes the list.
    func deleteConnection(connectionId: String) async {
        await perform(action: "delete the connection") {
            try await repository.delete(connectionId)
        }
    }

    /// Disconnects a connection and refreshes the list.
    func disconnectConnection(connectionId: String) async {
        await perform(action: "disconnect the connection") {
            try await repository.disconnect(connectionId)
        }
    }

    private func perform(action: String, _ work: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil

        do {
            try await work()
            await getConnections()
        } catch {
            Log.connections.error("Could not \(action): \(error.localizedDescription)")
            errorMessage = userMessage(for: error, whileTrying: action)
            isLoading = false
        }
    }
}
