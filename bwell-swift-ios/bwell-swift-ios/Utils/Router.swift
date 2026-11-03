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

@MainActor
final class NavigationRouter: ObservableObject {
    // The path that controls the navigation stack
    @Published var path: [AppRoute] = []

    // Push the new screen into the navigation path
    func navigate(to route: AppRoute) {
        path.append(route)
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
}
