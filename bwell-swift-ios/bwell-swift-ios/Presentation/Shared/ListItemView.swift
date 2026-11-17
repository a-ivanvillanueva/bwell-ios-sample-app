//
//  ListItemView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 07-11-2026.
//

import Foundation
import SwiftUI

struct ListItemView: View {
    @Environment(\.listItemIconAlignment) private var iconAlignment
    var title: LocalizedStringResource
    var description: LocalizedStringResource? = nil
    var icon: String
    var iconColor: Color
    var total: Int? = nil
    var hideNavArrow: Bool = false

    init(title: LocalizedStringResource, icon: String, iconColor: Color, hideNavArrow: Bool = false) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.hideNavArrow = hideNavArrow
    }

    init(title: LocalizedStringResource, description: LocalizedStringResource, icon: String, iconColor: Color, hideNavArrow: Bool = false) {
        self.title = title
        self.description = description
        self.icon = icon
        self.iconColor = iconColor
        self.hideNavArrow = hideNavArrow
    }

    init(title: LocalizedStringResource, icon: String, iconColor: Color, total: Int, hideNavArrow: Bool = false) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.total = total
        self.hideNavArrow = hideNavArrow
    }

    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: iconAlignment) {
                Image(systemName: icon)
                    .padding(.all, 5)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .background(iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading) {
                    Text(String(localized: title))
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.ink)

                    if let description = description {
                        Text(String(localized: description))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.muted)
                    }
                }

                if let total = total {
                    Spacer()
                    Text("\(total)")
                        .font(.system(size: 17))
                        .foregroundStyle(.muted)
                }
            }

            Spacer()

            if !hideNavArrow {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
            }
        }
    }
}

// MARK: Icon Custom Alignment
private struct ListItemIconAlignmentKey: EnvironmentKey {
    static let defaultValue: VerticalAlignment = .center
}

extension EnvironmentValues {
    var listItemIconAlignment: VerticalAlignment {
        get { self[ListItemIconAlignmentKey.self] }
        set { self[ListItemIconAlignmentKey.self] = newValue }
    }
}

extension View {
    func listItemIconAlignment(_ alignment: VerticalAlignment) -> some View {
        environment(\.listItemIconAlignment, alignment)
    }
}

// MARK: Preview
#Preview {
    ZStack {
        Color.canvas
            .ignoresSafeArea()

        List {
            ListItemView(title: .Home.activityOneTitle,
                         icon: "link", iconColor: .ink, total: 2)
            .listItemIconAlignment(.firstTextBaseline)

            ListItemView(title: .Connections.insurance,
                         description: .Connections.insuranceSubtext,
                         icon: "document", iconColor: .action)
            .listItemIconAlignment(.top)
        }
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .background(.canvas)
    }
}
