//
//  ConnectionViewModelTests.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 01-11-2026.
//

import Foundation
import Testing
@testable import bwell_swift_ios

@MainActor
struct ManageConnectionsViewModelTests {
    private func makeSUT() -> (ManageConnectionsViewModel, FakeConnectionRepository) {
        let repository = FakeConnectionRepository()
        repository.stored = [
            Connection(id: "1", name: "Sample Clinic", status: .connected),
            Connection(id: "2", name: "Sample Lab", status: .connected)
        ]
        return (ManageConnectionsViewModel(repository: repository), repository)
    }

    @Test func loadsTheConnections() async {
        let (viewModel, _) = makeSUT()

        await viewModel.getConnections()

        #expect(viewModel.memberConnections.count == 2)
        #expect(!viewModel.isLoading)
    }

    @Test func deletingRemovesTheConnectionAndRefreshesTheList() async {
        let (viewModel, repository) = makeSUT()
        await viewModel.getConnections()

        await viewModel.deleteConnection(connectionId: "1")

        #expect(repository.deletedIds == ["1"])
        #expect(viewModel.memberConnections.map(\.id) == ["2"])
    }

    @Test func disconnectingChangesTheStatusInTheList() async {
        let (viewModel, _) = makeSUT()
        await viewModel.getConnections()

        await viewModel.disconnectConnection(connectionId: "2")

        #expect(viewModel.memberConnections.first { $0.id == "2" }?.status == .disconnected)
    }

    @Test func aFailureSetsAMessageAndStopsLoading() async {
        let (viewModel, repository) = makeSUT()
        repository.error = TestError()

        await viewModel.deleteConnection(connectionId: "1")

        #expect(viewModel.errorMessage != nil)
        #expect(!viewModel.isLoading)
    }
}

@MainActor
struct SearchConnectionsViewModelTests {
    private let clinic = HealthResource(id: "1", name: "Clinic A", connectionId: "proa_demo")

    private func makeSUT() -> (SearchConnectionsViewModel, FakeHealthResourceRepository, FakeConnectionRepository) {
        let search = FakeHealthResourceRepository()
        let connections = FakeConnectionRepository()
        return (SearchConnectionsViewModel(searchRepository: search, connectionRepository: connections),
                search, connections)
    }

    @Test func showsTheResultsAndStopsLoading() async {
        let (viewModel, search, _) = makeSUT()
        search.results = [clinic]

        await viewModel.searchHealthResources(searchedText: "Clinic")

        #expect(viewModel.healthResources == [clinic])
        #expect(!viewModel.isLoading)
    }

    @Test func aSearchWithNoMatchesClearsThePreviousResults() async {
        let (viewModel, search, _) = makeSUT()
        search.results = [clinic]
        await viewModel.searchHealthResources(searchedText: "Clinic")

        search.results = []
        await viewModel.searchHealthResources(searchedText: "Nothing")

        #expect(viewModel.healthResources.isEmpty)
    }

    @Test func aSearchFailureSetsAMessage() async {
        let (viewModel, search, _) = makeSUT()
        search.error = TestError()

        await viewModel.searchHealthResources(searchedText: "Clinic")

        #expect(viewModel.errorMessage != nil)
        #expect(!viewModel.isLoading)
    }

    @Test func choosingAResourcePublishesTheSignInUrl() async {
        let (viewModel, _, connections) = makeSUT()

        await viewModel.requestOAuthURL(for: clinic)

        #expect(viewModel.oauthURL == connections.url)
    }
}
