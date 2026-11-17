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
            Color.canvas
                .ignoresSafeArea()

            if !viewModel.healthResources.isEmpty {
                resultsView
                    .padding(.top, 10)
            } else {
                VStack {
                    Spacer()

                    Circle()
                        .frame(width: 72, height: 72, alignment: .center)
                        .foregroundStyle(.sky)
                        .overlay {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 32, height: 32, alignment: .center)
                                .foregroundStyle(.indigoBrand)
                        }.padding(.bottom, 10)

                    Text(.Connections.findYourPlan)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.ink)
                        .padding(.bottom, 8)

                    Text(.Connections.searchPlanSubtext)
                        .font(.system(size: 15))
                        .foregroundStyle(.muted)

                    Spacer()
                }.padding(.horizontal)
            }
        }
        .navigationTitle(Text(connection.title))
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchedText, placement: .navigationBarDrawer,
                    prompt: Text(.Connections.searchBarPlaceholder))
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
            Button("Done") {

            }
        } message: {
            Text(.Connections.successfulAuthentication)
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
        List {
            Section(.Connections.searchResults(String(viewModel.healthResources.count))) {
                ForEach(viewModel.healthResources) { resource in
                    Button {
                        activeSheet = .terms(resource: resource)
                    } label: {
                        ListItemView(title: LocalizedStringResource(stringLiteral: resource.name),
                                     icon: "building", iconColor: .indigoBrand)
                    }
                }
            }
        }
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .background(.canvas)
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
    SearchConnectionsView(connection: .clinics,
                          viewModel: AppContainer.preview.makeSearchConnectionsViewModel())
}
