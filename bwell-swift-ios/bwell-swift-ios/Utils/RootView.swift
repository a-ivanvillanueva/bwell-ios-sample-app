//
//  RootView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 27/10/25.
//

import SwiftUI

struct RootView: View {
    let container: AppContainer

    @StateObject private var router = NavigationRouter()
    @StateObject private var sideMenuViewModel: SideMenuViewModel

    @State private var showMenu: Bool = false

    init(container: AppContainer) {
        self.container = container
        _sideMenuViewModel = StateObject(wrappedValue: container.makeSideMenuViewModel())
    }

    var body: some View {
        ZStack {
            NavigationStack(path: $router.path) {
                AuthenticationView(viewModel: container.makeAuthenticationViewModel())
                    .navigationDestination(for: AppRoute.self) { screen in
                        switch screen {
                        case .home:
                            HomeView(showMenu: $showMenu, viewModel: container.makeHomeViewModel())
                                .navigationBarBackButtonHidden()
                        case .profile:
                            ProfileView(showMenu: $showMenu, viewModel: container.makeProfileViewModel())
                                .navigationBarBackButtonHidden()
                        case .healthSummary:
                            HealthSummaryView(showMenu: $showMenu, viewModel: container.makeHealthSummaryViewModel())
                                 .navigationBarBackButtonHidden()
                        case .manageConnections:
                            ManageConnectionsView(showMenu: $showMenu, viewModel: container.makeManageConnectionsViewModel())
                                .navigationBarBackButtonHidden()
                        case .searchConnections(let connection):
                            SearchConnectionsView(connection: connection,
                                                  viewModel: container.makeSearchConnectionsViewModel())
                        case .connections:
                            ConnectionsView()
                        case .healthGroups(let category):
                            HealthGroupsView(category: category,
                                             viewModel: container.makeHealthGroupsViewModel(for: category))
                        case .healthRecords(let category, let group):
                            HealthRecordsView(category: category,
                                              viewModel: container.makeHealthRecordsViewModel(for: category, group: group))
                        }
                    }
            }
            
            SideMenuView(isShowing: $showMenu, viewModel: sideMenuViewModel)
        }
        .environmentObject(router)
        .environmentObject(sideMenuViewModel)
        .onReceive(container.session.authStatePublisher) {
            handleAuthStateChange($0)
        }
    }

    private func handleAuthStateChange(_ state: AuthState) {
        switch state {
        case .signedIn:
            if router.path.isEmpty {
                router.path  = [.home]
            }
        case .signedOut:
            router.navigateToRoot()
        }
    }
}
