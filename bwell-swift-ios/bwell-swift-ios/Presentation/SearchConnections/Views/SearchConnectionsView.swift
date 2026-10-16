//
//  SearchConnectionsView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 07/11/25.
//
import Foundation
import SwiftUI

struct SearchConnectionsView: View {
    private let connection: ConnectionsModel

    @Environment(\.dismissSearch) private var dismissSearch
    @EnvironmentObject private var router: NavigationRouter

    @StateObject private var viewModel: SearchConnectionsViewModel

    @State private var searchedText: String = ""
    @State private var activeSheet: SheetContent?
    @State private var showOnSuccessMessage: Bool = false
    @State private var pendingWebURL: URL?
    @State private var shouldShowSuccess = false

    init(connection: ConnectionsModel,
         viewModel: @autoclosure @escaping () -> SearchConnectionsViewModel) {
        self.connection = connection
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            if !viewModel.healthResources.isEmpty {
                resultsView
                    .padding(.top, 10)
            } else {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.bottom, 10)

                    Text("Search by clinic/medical office name, hospital name. health system name, or city/state.")
                }.padding(.horizontal)
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarBackground(.bwellPurple, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text(connection.title))
        .searchable(text: $searchedText, placement: .toolbar, prompt: Text("Search"))
        .submitLabel(.search)
        .onSubmit(of: .search) {
            Task {
                await viewModel.searchHealthResources(searchedText: searchedText)
            }
            dismissSearch()
        }
        .sheet(item: $activeSheet, onDismiss: presentNextStep) { sheetContent in
            switch sheetContent {
            case .terms(let resource):
                SearchConnectionDisclaimerView(resourceTitle: resource.name) {
                    Task {
                        await viewModel.requestOAuthURL(for: resource)
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)

            case .webView(let url):
                WebViewWrapper(url: url) {
                    shouldShowSuccess = true
                    activeSheet = nil
                }
            }
        }
        .onChange(of: viewModel.oauthURL) { _, url in
            guard let url else {
                return
            }

            pendingWebURL = url
            activeSheet = nil
            viewModel.oauthURL = nil

        }
        .alert("Success!", isPresented: $showOnSuccessMessage) {
            Button("Done") {}
        } message: {
            Text("Authentication successful!")
        }
        .onChange(of: showOnSuccessMessage) { _, newValue in
            if !newValue {
                router.navigateAndReplace(to: .manageConnections)
            }
        }
    }

    // MARK: Results view
    @ViewBuilder
    var resultsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Results (\(viewModel.healthResources.count))")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.bottom, 5)

            List {
                ForEach(viewModel.healthResources) { resource in
                    Button {
                        activeSheet = .terms(resource: resource)
                    } label: {
                        ListItem(title: resource.name)
                    }
                }
            }.listStyle(.plain)
        }.padding(.horizontal)
    }

    private func presentNextStep() {
        if let url = pendingWebURL {
            pendingWebURL = nil
            activeSheet = .webView(url: url)
        } else if shouldShowSuccess {
            shouldShowSuccess = false
            showOnSuccessMessage = true
        }
    }
}

private struct ListItem: View {
    var title: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "person.circle")
                .frame(width: 25, alignment: .leading)

            Text(title)
                .font(.headline)
                .fontWeight(.medium)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }.listRowSeparator(.hidden, edges: .all)
    }
}

#Preview {
    SearchConnectionsView(connection: .clinics, viewModel: AppContainer.preview.makeSearchConnectionsViewModel())
        .environmentObject(AppContainer.preview.makeSideMenuViewModel())
        .environmentObject(NavigationRouter())
}
