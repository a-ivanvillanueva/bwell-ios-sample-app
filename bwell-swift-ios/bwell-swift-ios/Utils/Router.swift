//
//  Router.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 27/10/25.
//

import Foundation
import SwiftUI

enum AppRoute: Hashable {
    case home
    case profile
    case healthSummary
    case manageConnections

    // Subviews of manageConnections
    case connections
    case searchConnections(connection: ConnectionsModel)

    // Health
    case healthGroups(HealthCategory)
    case healthRecords(category: HealthCategory, group: HealthGroup)
}

enum AppSheet: Identifiable {
    case addConnection; var id: Self { self }
}

@MainActor
final class NavigationRouter: ObservableObject {
    // The path that controls the navigation stack
    @Published var path: [AppRoute] = []
    @Published var selectedTab: AppTab = .home
    @Published var paths: [AppTab : [AppRoute]] = [:]
    @Published var sheet: AppSheet?

    // Create a custom two way communication for the tabView navigation
    func binding(for tab: AppTab) -> Binding<[AppRoute]> {
        Binding {
            self.paths[tab, default: []]
        } set: {
            self.paths[tab] = $0
        }
    }

    // Push the new screen into the navigation path
    func navigate(to route: AppRoute) {
        paths[selectedTab, default: []].append(route)
    }

    // Navigate to a specific destination, clearing the current path first
    func navigateAndReplace(to route: AppRoute) {
        path = [route]
    }

    // Navigate to the previous screen
    func goBack() {
       _ =  path.popLast()
    }

    // Navigates back to the root of the navigation stack.
    func navigateToRoot() {
        guard !path.isEmpty else { return }
        path.removeAll()
    }

    // Cross-tab: Home's card opens the Add connection sheet on the Connections tab.
        func openAddConnection() {
            selectedTab = .connections
            sheet = .addConnection
        }

    // Resets the navigation to the default view (Home)
    func reset() {
        selectedTab = .home
        paths = [:]
    }
}
