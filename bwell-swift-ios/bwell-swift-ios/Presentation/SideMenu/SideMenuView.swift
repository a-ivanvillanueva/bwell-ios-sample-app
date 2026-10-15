//
//  SideMenuView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 27/10/25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @StateObject var viewModel: SideMenuViewModel
    @EnvironmentObject var router: NavigationRouter

    init(isShowing: Binding<Bool>, viewModel: @autoclosure @escaping () -> SideMenuViewModel) {
        _isShowing = isShowing
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            if isShowing {
                Rectangle()
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { isShowing.toggle() }
                    // .toolbarBackground(.bwellPurple, for: .navigationBar)
                    // .toolbarVisibility(.visible, for: .navigationBar)

                HStack {
                    VStack(alignment: .leading, spacing: 32) {
                        HeaderView()
                        VStack {
                            ForEach(SideMenuModel.allCases.dropLast()) { option in
                                Button(action: {
                                    viewModel.navigate(to: option)
                                    isShowing = false
                                }, label: {
                                    RowView(option: option,
                                            selectedOption: $viewModel.optionSelected)
                                })
                            }
                        }
                        Spacer()

                        Button(action: {
                            viewModel.navigate(to: .logout)
                            isShowing = false
                        }, label: {
                            RowView(option: .logout,
                                    selectedOption: .constant(.logout))
                        })
                    }
                    .padding()
                    .frame(width: 270, alignment: .leading)
                    .background(.white)

                    Spacer()
                }
            }
        }
        .transition(.move(edge: .leading))
        .animation(.easeInOut, value: isShowing)
        .task {
            viewModel.setup(router: router)
            if viewModel.optionSelected == nil {
                viewModel.optionSelected = .home
            }
        }
    }
}

private struct HeaderView: View {
    var body: some View {
        HStack {
            Image("user-profile-picture")
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .padding(.vertical)

            VStack(alignment: .leading, spacing: 4) {
                Text("Sample App User")
                    .fontWeight(.semibold)
                    .font(.subheadline)

                Text("test@test.test")
                    .font(.footnote)
                    .tint(.gray)
            }
        }
    }
}

private struct RowView: View {
    var option: SideMenuModel
    @Binding var selectedOption: SideMenuModel?

    private var isSelected: Bool {
        return selectedOption == option
    }

    var body: some View {
        HStack {
            Image(systemName: option.iconName)
                .imageScale(.small)
                .foregroundStyle(selectedOption == .logout ? .red : .bwellPurple)

            Text(option.title)
                .font(.subheadline)
                .foregroundStyle(selectedOption == .logout ? .red : .black)
            Spacer()
        }
        .padding(.leading)
        .frame(height: 44)
        .background((isSelected && selectedOption != .logout) ? .bwellPurple.opacity(0.25) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
