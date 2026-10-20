//
//  Hee.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 19-10-2026.
//

import Foundation
import SwiftUI

struct HealthRecordsView: View {
    @StateObject private var viewModel: LoadableViewModel<[HealthRecord]>
    @State private var selectedRecord: HealthRecord?

    let category: HealthCategory

    init(category: HealthCategory,
         viewModel: @autoclosure @escaping () -> LoadableViewModel<[HealthRecord]>) {
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
                List(viewModel.value) { record in
                    Button {
                        selectedRecord = record
                    } label: {
                        HealthRowView(title: record.title, date: record.date, value: record.value)
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
        .sheet(item: $selectedRecord) { record in
            HealthRecordDetailView(record: record)
        }
    }
}
