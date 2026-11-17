//
//  BWellTabView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 06-11-2026.
//

import Foundation
import SwiftUI

struct BWellTabView: View {
    @EnvironmentObject private var router: NavigationRouter
    let container: AppContainer

    var body: some View {
        TabView(selection: $router.selectedTab) {
            Tab("Home", systemImage: "house", value: AppTab.home) {
                NavigationStack(path: router.binding(for: .home)) {
                    HomeView(viewModel: container.makeHomeViewModel())
                        .appDestinations(container: container)
                }
            }

            Tab("Health", systemImage: "heart", value: AppTab.health) {
                NavigationStack(path: router.binding(for: .health)) {
                    HealthSummaryView(viewModel: container.makeHealthSummaryViewModel())
                        .appDestinations(container: container)
                }
            }

            Tab("Connections", systemImage: "link", value: AppTab.connections) {
                NavigationStack(path: router.binding(for: .connections)) {
                    ManageConnectionsView(container: container, viewModel: container.makeManageConnectionsViewModel())
                        .appDestinations(container: container)
                }
            }

            Tab("Profile", systemImage: "person", value: AppTab.profile) {
                NavigationStack(path: router.binding(for: .profile)) {
                    ProfileView(showMenu: .constant(false), viewModel: container.makeProfileViewModel())
                        .appDestinations(container: container)
                }
            }
        }
    }
}
