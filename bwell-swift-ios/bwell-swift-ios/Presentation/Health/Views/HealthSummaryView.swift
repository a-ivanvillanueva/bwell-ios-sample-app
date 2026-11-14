//
//  HealthSummaryView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 28/10/25.
//
import Foundation
import SwiftUI

struct HealthSummaryView: View {
    @StateObject private var viewModel: LoadableViewModel<[HealthCategory: Int]>

    init(viewModel: @autoclosure @escaping () -> LoadableViewModel<[HealthCategory: Int]>) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(HealthCategory.allCases) { category in
                    NavigationLink(value: AppRoute.healthGroups(category)) {
                        ListItemView(title: category.title,
                                     icon: category.icon,
                                     iconColor: category.iconColor, total: viewModel.value[category] ?? 0)
                    }.navigationLinkIndicatorVisibility(.hidden)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
            .background(.canvas)
            .navigationTitle(String(localized: LocalizedStringResource.Health.healthTitle))
            .task {
                await viewModel.load()
            }
        }
    }
}

#Preview {
    HealthSummaryView(viewModel: AppContainer.preview.makeHealthSummaryViewModel())
}
