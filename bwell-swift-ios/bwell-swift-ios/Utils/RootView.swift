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
    @State private var authState: AuthState

    @State private var showMenu: Bool = false

    init(container: AppContainer) {
        self.container = container
        _authState = State(initialValue: container.session.authState)
    }

    var body: some View {
        Group {
            switch authState {
            case .signedOut:
                AuthenticationView(viewModel: container.makeAuthenticationViewModel())
            case .signedIn:
                BWellTabView(container: container)
            }
        }
        .environmentObject(router)
        .onReceive(container.session.authStatePublisher) { newState in
            if newState == .signedOut {
                router.reset()
            }
            authState = newState
        }
    }
}
