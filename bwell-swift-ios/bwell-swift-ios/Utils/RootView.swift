//
//  RootView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 27/10/25.
//

import SwiftUI
import BWellSDK

struct RootView: View {
    let container: AppContainer

    @StateObject private var router = NavigationRouter()
    @StateObject private var sideMenuViewModel: SideMenuViewModel
    @StateObject private var healthSummaryViewModel: HealthSummaryViewModel

    @State private var showMenu: Bool = false

    init(container: AppContainer) {
        self.container = container
        _sideMenuViewModel = StateObject(wrappedValue: container.makeSideMenuViewModel())
        _healthSummaryViewModel = StateObject(wrappedValue: container.makeHealthSummaryViewModel())
    }

    var body: some View {
        ZStack {
            NavigationStack(path: $router.path) {
                AuthenticationView(viewModel: container.makeAuthenticationViewModel())
                    .navigationDestination(for: AppView.self) { screen in
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
                        case .healthGroupItems(let category, let groupCode):
                            // Health data summary detail views
                            HealthDataFactoryView(category, groupCode)
                        }
                    }
            }
            
            SideMenuView(isShowing: $showMenu, viewModel: sideMenuViewModel)
        }
        .environmentObject(router)
        .environmentObject(sideMenuViewModel)
        .environmentObject(healthSummaryViewModel)
        .onReceive(container.session.statePublisher) {
            handleStateChange($0)
        }
    }

    private func handleStateChange(_ state: SessionState) {
        switch state {
        case .authenticated:
            if router.path.isEmpty {
                router.path = NavigationPath([AppView.home])
            }
        case .uninitialized, .unauthenticated, .failed:
            router.navigateToRoot()
        case .initializing, .authenticating, .initialized, .checkingSession:
            break
        }
    }
}
