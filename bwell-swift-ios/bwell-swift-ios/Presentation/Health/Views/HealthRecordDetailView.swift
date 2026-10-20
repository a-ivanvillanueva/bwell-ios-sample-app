//
//  HealthRecordDetailView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 19-10-2026.
//

import Foundation
import SwiftUI

struct HealthRecordDetailView: View {
    let record: HealthRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(record.heading ?? "Title unavailable")
                .font(.headline)
                .fontWeight(.medium)
                .padding(.vertical, 20)

            ForEach(Array(record.details.enumerated()), id: \.offset) { _, detail in
                DetailedItemView(
                    display: detail.kind == .stackedText ? .vertically : .horizontally,
                    title: detail.label,
                    content: detail.kind == .date ? detail.content.dateFormatter() : detail.content
                )
            }

            if !record.notes.isEmpty {
                Text("Notes:")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 10)

                ForEach(Array(record.notes.enumerated()), id: \.offset) { _, note in
                    HStack {
                        Text(note.text)
                        Spacer()
                        Text(note.date?.dateFormatter() ?? "")
                    }
                }
            }

            Spacer()
        }
        .padding()
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium])
    }
}
