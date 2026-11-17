//
//  SearchConnectionDisclaimerView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 07/11/25.
//
import Foundation
import SwiftUI

enum SheetContent: Identifiable {
    case terms(resource: HealthResource)
    case webView(url: URL)

    var id: String {
        switch self {
        case .terms(let resource): resource.connectionId
        case .webView(let url): url.absoluteString
        }
    }
}

struct SearchConnectionDisclaimerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var termsAccepted = false

    var resourceTitle: String
    var action: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.canvas
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: .zero) {
                    ListItemView(title: LocalizedStringResource(stringLiteral: resourceTitle),
                                 description: .Connections.connectionDisclaimer, icon: "building", iconColor: .indigoDeep, hideNavArrow: true)

                    Group {
                        Text("NOTE")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.ink)
                            .frame(alignment: .leading)
                            .padding(.top, 20)

                        Text(.Connections.connectionNote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 17))
                            .foregroundStyle(.ink)
                            .padding(.vertical, 12)
                    }

                    Toggle(isOn: $termsAccepted) {
                        Text(.Connections.disclaimerTerms)
                            .font(.system(size: 17))
                            .foregroundStyle(.ink)
                            .multilineTextAlignment(.leading)
                    }
                    .toggleStyle(.switch)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .tint(.action)

                    Spacer()

                    Group {
                        BWellButton(title: .Connections.proceedButton, textColor: .white,
                                    buttonColor: termsAccepted ? .action : .action.opacity(0.4)) {
                            Log.ui.debug("Proceed button pressed.")
                            action()
                        }

                        Text(.Connections.disclaimerInstructions)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.system(size: 13))
                            .foregroundStyle(.muted)
                            .padding(.top, 12)
                    }
                }
                .background(.canvas)
                .padding(.horizontal, 16)
                .navigationTitle(Text(.Connections.disclaimerTitle))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 17))
                                .foregroundStyle(.action)
                        }
                    }
                }
            }
        }
    }
}
