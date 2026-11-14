//
//  ListItemView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 07-11-2026.
//

import Foundation
import SwiftUI

struct ListItemView: View {
    var title: LocalizedStringResource
    var description: LocalizedStringResource? = nil
    var icon: String
    var iconColor: Color
    var total: Int? = nil

    init(title: LocalizedStringResource, description: LocalizedStringResource, icon: String, iconColor: Color) {
        self.title = title
        self.description = description
        self.icon = icon
        self.iconColor = iconColor
    }

    init(title: LocalizedStringResource, icon: String, iconColor: Color, total: Int) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.total = total
    }

    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: icon)
                    .padding(.all, 5)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .background(iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading) {
                    Text(String(localized: title))
                        .font(.system(size: 17))
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

            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
    }
}
#Preview {
    ListItemView(title: .Home.activityOneTitle,
                 icon: "link", iconColor: .ink, total: 2)
        .padding(.horizontal, 16)
}
