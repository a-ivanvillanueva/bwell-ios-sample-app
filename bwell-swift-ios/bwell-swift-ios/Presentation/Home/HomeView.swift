//
//  HomeView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 10/11/25.
//
import Foundation
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: @autoclosure @escaping () -> HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            Color.canvas
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                Group {
                    Text("Welcome, \(viewModel.firstName)!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.bottom, 8)
                        // .frame(width: .infinity, alignment: .leading)

                    BannerView(title: .Home.bannerTitle,
                               description: .Home.bannerDescription,
                               buttonTitle: .Home.bannerButtonTitle)
                    .transition(.slide)
                }.padding(.horizontal, 16)

                List {
                    Section("Suggested for you") {
                        ListItemView(title: .Home.activityOneTitle,
                                             description: .Home.activityOneDescription,
                                             icon: "link", iconColor: .ink)

                        ListItemView(title: .Home.activityTwoTitle,
                                             description: .Home.activityTwoDescription,
                                             icon: "heart", iconColor: .alert)

                        ListItemView(title: .Home.activityThreeTitle,
                                             description: .Home.activityThreeDescription,
                                             icon: "person", iconColor: .action)
                    }.headerProminence(.increased)
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .background(.canvas)
                .padding(.top, 20)
            }
        }
    }
}

// MARK: Banner View
private struct BannerView: View {
    @State private var shouldClose: Bool = false

    var title: LocalizedStringResource
    var description: LocalizedStringResource
    var buttonTitle: LocalizedStringResource

    var body: some View {
        if !shouldClose {
            VStack(alignment: .leading, spacing: 10) {
                Text(String(localized: title))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)

                Text(String(localized: description))
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .padding(.bottom, 10)

                Button {
                    Log.ui.debug("Banner tapped")
                } label: {
                    Text(String(localized: buttonTitle))
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .foregroundStyle(.indigoBrand)
                        .fontWeight(.semibold)
                        .background(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.indigoBrand)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .transition(.asymmetric(insertion: .scale, removal: .opacity))
            .overlay(alignment: .topTrailing) {
                Button {
                    shouldClose = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .padding(.all, 5)
                        .rotationEffect(.degrees(45))
                        .font(.system(size: 30))
                        .foregroundStyle(.sky, .muted)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: shouldClose)
        }
    }
}

#Preview {
    HomeView(viewModel: AppContainer.preview.makeHomeViewModel())
        .environmentObject(NavigationRouter())
}
