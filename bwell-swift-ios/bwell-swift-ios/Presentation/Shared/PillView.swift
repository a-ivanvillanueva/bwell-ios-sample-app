//
//  PillView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 10-11-2026.
//

import Foundation
import SwiftUI

struct PillView: View {
    var icon: String = ""
    var text: String
    var textColor: Color
    var pillColor: Color

    var body: some View {
        HStack(spacing: 4) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.success)
                    .opacity(1)
            }

            Text(text.capitalizingFirstLetter())
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(textColor)
                .opacity(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(pillColor)
        .clipShape(.capsule)
    }
}
