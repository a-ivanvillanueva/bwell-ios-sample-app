//
//  HealthRowView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 19-10-2026.
//

import Foundation
import SwiftUI

struct HealthRowView: View {
    let title: String?
    var date: String? = nil
    var value: String? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title?.capitalizingFirstLetter() ?? "Unknown title")

            Spacer()

            if let value {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .frame(width: 24)
                .foregroundStyle(.gray)
        }
    }
}
