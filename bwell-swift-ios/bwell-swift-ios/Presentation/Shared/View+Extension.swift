//
//  View+Extension.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 06-11-2026.
//

import Foundation
import SwiftUI

extension View {
    func appDestinations(container: AppContainer) -> some View {
        self.navigationDestination(for: AppRoute.self) { screen in
            switch screen {
            case .searchConnections(let connection):
                SearchConnectionsView(connection: connection, viewModel: container.makeSearchConnectionsViewModel())

            case .connections:
                ConnectionsView()

            case .healthGroups(let category):
                HealthGroupsView(category: category, viewModel: container.makeHealthGroupsViewModel(for: category))

            case .healthRecords(let category, let group):
                HealthRecordsView(category: category,group: group, viewModel: container.makeHealthRecordsViewModel(for: category, group: group))

            default: EmptyView()
            }
        }
    }
}
