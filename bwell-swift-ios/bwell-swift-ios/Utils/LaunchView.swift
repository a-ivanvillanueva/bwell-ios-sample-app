//
//  LaunchView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 12/11/25.
//
import Foundation
import SwiftUI

struct LaunchView: View {
    let container: AppContainer

    @StateObject private var viewModel: LaunchViewModel

    init(container: AppContainer, viewModel: LaunchViewModel) {
        self.container = container
        _viewModel = StateObject(wrappedValue: container.makeLaunchViewModel())
    }

    var body: some View {
        Group {
            if viewModel.isCheckingSession {
                ZStack {
                    Color.bwellPurple.ignoresSafeArea()

                    Image("bwell-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .padding(.bottom, 40)
                }
            } else {
                RootView(container: container)
            }
        }.onAppear {
            Task {
                await viewModel.checkSession()
            }
        }
    }
}

@MainActor
final class LaunchViewModel: ObservableObject {
    private let session: SessionRepository
    private let apiKeyStore: APIKeyStore

    @Published var isCheckingSession: Bool = true


    init(session: SessionRepository, apiKeyStore: APIKeyStore) {
        self.session = session
        self.apiKeyStore = apiKeyStore
    }

    func checkSession() async {
        guard let apiKey = apiKeyStore.getAPIKey() else {
            isCheckingSession = false
            return
        }

        do {
            try await session.initialize(apiKey)
            await session.validateSession()
        } catch {
            Log.sdk.error("Launch: SDK initialization failed: \(error.localizedDescription)")
        }

        isCheckingSession = false
    }
}
