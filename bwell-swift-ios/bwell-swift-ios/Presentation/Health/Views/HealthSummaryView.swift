//
//  HealthSummaryView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 28/10/25.
//
import Foundation
import SwiftUI

struct HealthSummaryView: View {
    @EnvironmentObject private var router: NavigationRouter

    @StateObject private var viewModel: LoadableViewModel<[HealthCategory: Int]>
    @Binding private var showMenu: Bool

    init(showMenu: Binding<Bool>,
         viewModel: @autoclosure @escaping () -> LoadableViewModel<[HealthCategory: Int]>) {
        _showMenu = showMenu
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        List {
            ForEach(HealthCategory.allCases) { category in
                Button {
                    router.navigate(to: .healthGroups(category))
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .frame(width: 24, alignment: .center)

                        Text(category.title)

                        Spacer()

                        if viewModel.isLoading {
                            ProgressView()
                        } else if let total = viewModel.value[category] {
                            Text("\(total)")
                                .foregroundStyle(.secondary)
                        }

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .frame(width: 24)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        .padding(.top, 10)
        .bwellNavigationBar(showMenu: $showMenu, navigationTitle: "Health Summary")
        .listStyle(.plain)
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    HealthSummaryView(showMenu: .constant(false),
                      viewModel: AppContainer.preview.makeHealthSummaryViewModel())
        .environmentObject(NavigationRouter())
        .environmentObject(AppContainer.preview.makeSideMenuViewModel())
}
