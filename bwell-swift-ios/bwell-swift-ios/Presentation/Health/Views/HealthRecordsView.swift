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
    let group: HealthGroup

    init(category: HealthCategory,
         group: HealthGroup,
         viewModel: @autoclosure @escaping () -> LoadableViewModel<[HealthRecord]>) {
        self.category = category
        self.group = group
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            Color.canvas
                .ignoresSafeArea()
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
                        HStack(alignment: .center, spacing: 12) {
                            Text(record.title?.capitalizingFirstLetter() ?? "Unknown record")
                                .font(.system(size: 17))
                                .foregroundStyle(.black)

                            Spacer()

                            if let value = record.value {
                                PillView(text: value, textColor: .indigoBrand, pillColor: .sky)
                            }

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .frame(width: 24)
                                .foregroundStyle(.muted)
                        }

                    }
                }.scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(Text(String("\(group.name ?? "No name")")))
        .task { await viewModel.load() }
        .sheet(item: $selectedRecord) { record in
            HealthRecordDetailView(category: category, group: group, record: record)
        }
    }
}
