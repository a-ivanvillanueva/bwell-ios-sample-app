//
//  ConnectionsView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 06/11/25.
//
import Foundation
import SwiftUI

struct AddNewConnectionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: .zero) {
                Group {
                    Text(.Connections.addConnectionQuestion)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.ink)
                        .padding(.top, 12)
                        .padding(.bottom, 4)

                    Text(.Connections.addConnectionSubtext)
                        .font(.system(size: 15))
                        .foregroundStyle(.muted)
                }.padding(.horizontal, 20)

                List {
                    NavigationLink(value: AppRoute.searchConnections(connection: .insurance)) {
                        ListItemView(title: .Connections.insurance,
                                     description: .Connections.insuranceSubtext,
                                     icon: "document", iconColor: .action)
                        .listItemIconAlignment(.top)
                        
                    }.navigationLinkIndicatorVisibility(.hidden)

                    NavigationLink(value: AppRoute.searchConnections(connection: .providers)) {
                        ListItemView(title: .Connections.providers,
                                     description: .Connections.providersSubtext,
                                     icon: "plus", iconColor: .alert)
                        .listItemIconAlignment(.top)
                    }.navigationLinkIndicatorVisibility(.hidden)

                    NavigationLink(value: AppRoute.searchConnections(connection: .clinics)) {
                        ListItemView(title: .Connections.clinics,
                                     description: .Connections.clinicsSubtext,
                                     icon: "building", iconColor: .ink)
                        .listItemIconAlignment(.top)
                    }.navigationLinkIndicatorVisibility(.hidden)

                    NavigationLink(value: AppRoute.searchConnections(connection: .labs)) {
                        ListItemView(title: .Connections.labs,
                                     description: .Connections.labsSubtext,
                                     icon: "flask", iconColor: .success)
                        .listItemIconAlignment(.top)
                    }.navigationLinkIndicatorVisibility(.hidden)
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .background(.canvas)

                Spacer()
            }
            .navigationTitle(Text(.Connections.addConnection))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 17))
                            .foregroundStyle(.action)
                    }
                }
            }
            .background(.canvas)
        }
    }
}

#Preview {
    AddNewConnectionView()
}
