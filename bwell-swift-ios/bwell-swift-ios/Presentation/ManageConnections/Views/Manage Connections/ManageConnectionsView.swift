//
//  ManageConnectionsView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 31/10/25.
//

import Foundation
import SwiftUI

struct ManageConnectionsView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel: ManageConnectionsViewModel
    @State private var showAddConnectionsSheet: Bool = false
    let container: AppContainer

    init(container: AppContainer, viewModel: @autoclosure @escaping () -> ManageConnectionsViewModel) {
        self.container = container
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: .zero) {
                Text(.Connections.subtitle)
                    .font(.system(size: 15))
                    .foregroundStyle(.muted)
                    .padding([.horizontal, .bottom], 16)
                    .padding(.top, 4)

                List {
                    ForEach(viewModel.memberConnections, id: \.id) { connection in
                        ConnectionListItem(
                            connection: connection,
                            onDelete: {
                                Task {
                                    await viewModel.deleteConnection(connectionId: connection.id)
                                }
                            },
                            onDisconnect: {
                                Task {
                                    await viewModel.disconnectConnection(connectionId: connection.id)
                                }
                            }
                        )
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .background(.canvas)
                .task {
                    if viewModel.memberConnections.isEmpty {
                        await viewModel.getConnections()
                    }
                }
            }
            .navigationTitle(Text(.Connections.navigationTitle))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddConnectionsSheet = true
                        router.sheet = .addConnection
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.indigoBrand)
                    }
                }
            }
            .sheet(item: $router.sheet) { _ in
                AddNewConnectionView(container: container)
            }
            .background(.canvas)
        }
    }
}

private struct ConnectionListItem: View {
    let connection: Connection
    let onDelete: () -> Void
    let onDisconnect: () -> Void

    @State private var showActionSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showDisconnectConfirmation = false

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "link")
                .padding(.all, 5)
                .font(.system(size: 16))
                .foregroundStyle(.ink)
                .background(.hairline)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(connection.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.ink)

                if connection.status == .connected {
                    PillView(icon: "checkmark",
                             text: connection.status.displayName.lowercased().capitalizingFirstLetter(),
                             textColor: .success,
                             pillColor: .successOn)
                } else {
                    PillView(icon: "minus",
                             text: connection.status.displayName.lowercased().capitalizingFirstLetter(),
                             textColor: .muted,
                             pillColor: .sky)
                }
            }

            Spacer()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false, content: {
            if connection.status == .connected {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Text(.Connections.delete)
                    Image(systemName: "trash")
                }.tint(.alert)
            }

            Button {
                Log.ui.debug("New connection complete")
            } label: {
                if connection.status == .connected {
                    Group {
                        Text(.Connections.disconnect)
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    }
                } else {
                    Group {
                        Text(.Connections.connect)
                        Image(systemName: "antenna.radiowaves.left.and.right")
                    }
                }
            }.tint(connection.status == .connected ? .muted : .success)
        })
        .alert(.Connections.disconnectAlertTitle, isPresented: $showDisconnectConfirmation) {
            Button(.Connections.cancel, role: .cancel) { }
            Button(.Connections.disconnect, role: .destructive) {
                onDisconnect()
            }
        } message: {
            Text(.Connections.disconnectionAlertMessage(connection.name))
        }
        .alert(.Connections.deleteConnection, isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text(.Connections.deleteConnectionMessageAlert(connection.name))
        }
    }
}

