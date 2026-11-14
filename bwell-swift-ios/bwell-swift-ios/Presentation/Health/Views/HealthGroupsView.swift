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
                    NavigationLink(value: AppRoute.healthRecords(category: category, group: group)) {
                        if let name = group.name {
                            Text("\(name)")
                                .font(.system(size: 17))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .background(.canvas)
            }
        }
        .navigationTitle(category.title)
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    HealthGroupsView(category: .allergyIntolerance,
                     viewModel: AppContainer.preview.makeHealthGroupsViewModel(for: .allergyIntolerance))
}
