//
//  HealthRecordDetailView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 19-10-2026.
//

import Foundation
import SwiftUI

struct HealthRecordDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let category: HealthCategory
    let group: HealthGroup
    let record: HealthRecord

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.action)
                }
            }.padding([.top, .trailing])

            HStack(spacing: 8) {
                PillView(text: String(localized: category.title), textColor: .indigoBrand, pillColor: .sky)

                if let value = record.value {
                    PillView(text: value, textColor: .muted, pillColor: .sky)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: .zero) {
                ForEach(Array(record.details.enumerated()), id: \.offset) { _, detail in

                    RecordDetailsView(display: detail.kind == .stackedText ? .vertically : .horizontally,
                                      title: detail.label,
                                      content: detail.kind == .date ? detail.content.dateFormatter() : detail.content
                    )
                    Divider()
                        .frame(height: 1)
                        .padding(.leading, 30)
                }
            }.clipShape(RoundedRectangle(cornerRadius: 12))

            if !record.notes.isEmpty {
                Text("NOTES")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.ink)
                    .frame(alignment: .leading)
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                ForEach(Array(record.notes.enumerated()), id: \.offset) { _, note in
                    VStack(alignment: .leading, spacing: 18) {
                        Text(note.text)
                            .font(.system(size: 17))
                            .foregroundStyle(.ink)

                        Text(note.date?.dateFormatter() ?? "")
                            .font(.system(size: 13))
                            .foregroundStyle(.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.bar)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Spacer()
        }
        .ignoresSafeArea()
        .padding(.horizontal, 16)
        .background(.white)
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium])
    }
}

private struct RecordDetailsView: View {
    var display: Direction = .horizontally
    var title: String
    var content: String?

    var body: some View {
        Group {
            if display == .vertically {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 13))
                        .foregroundStyle(.muted)

                    Text(content ?? "")
                        .font(.system(size: 17))
                        .foregroundStyle(.ink)
                }.frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(alignment: .top, spacing: .zero) {
                    Text(title)
                        .font(.system(size: 15))
                        .foregroundStyle(.muted)

                    Spacer()

                    Text(content ?? "")
                        .font(.system(size: 17))
                        .foregroundStyle(.ink)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
        .padding(.horizontal, 16)
        .background(.bar)
    }
}

private enum Direction {
    case horizontally, vertically
}
