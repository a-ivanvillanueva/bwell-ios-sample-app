//
//  HealthGroupsView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 19-10-2026.
//

import Foundation
import SwiftUI

struct HealthGroupsView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel: LoadableViewModel<[HealthGroup]>

    let category: HealthCategory

    init(category: HealthCategory,
         viewModel: @autoclosure @escaping () -> LoadableViewModel<[HealthGroup]>) {
        self.category = category
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.value.isEmpty {
                ProgressView("Loading data...")
            } else if let message = viewModel.errorMessage, viewModel.value.isEmpty {
                Text(message)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                List(viewModel.value) { group in
                    Button {
                        router.navigate(to: .healthRecords(category: category, group: group))
                    } label: {
                        HealthRowView(title: group.name, date: group.date)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(category.title)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarBackground(.bwellPurple, for: .navigationBar)
        .task { await viewModel.load() }
    }
}
