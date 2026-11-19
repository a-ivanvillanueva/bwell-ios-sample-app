//
//  ProfileView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 28/10/25.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    @State private var text: String = ""
    @State private var isEditing: Bool = false

    init(viewModel: @autoclosure @escaping () -> ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.canvas
                    .ignoresSafeArea()

                if isEditing {
                    editProfile
                        .navigationTitle(Text("Edit Profile"))
                        .navigationBarTitleDisplayMode( .inline)
                        .padding(.top, 5)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    isEditing = false
                                } label: {
                                    Text("Cancel")
                                        .font(.system(size: 17))
                                        .foregroundStyle(.action)
                                }
                            }

                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    Log.profile.log("Save button pressed")
                                    Task {
                                        await viewModel.updateUserProfile()
                                        isEditing = false
                                    }
                                } label: {
                                    Text("Save")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.action)
                                }
                            }
                        }
                } else {
                    userProfile
                        .scrollContentBackground(.hidden)
                        .background(.canvas)
                        .navigationTitle(Text("Profile"))
                        .navigationBarTitleDisplayMode(.large)
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    isEditing = true
                                } label: {
                                    Text("Edit")
                                        .font(.system(size: 17))
                                        .foregroundStyle(.action)
                                }
                            }
                        }
                        .task {
                            await viewModel.getUserProfile()
                        }
                }
            }
        }
    }

    @ViewBuilder
    var editProfile: some View {
        EditableProfileView(givenName: $viewModel.givenName,
                            familyName: $viewModel.familyName,
                            gender: $viewModel.gender,
                            email: $viewModel.email,
                            workPhone: $viewModel.workPhone,
                            homePhone: $viewModel.homePhone,
                            mobilePhone: $viewModel.mobilePhone,
                            addressLineOne: $viewModel.addressLineOne,
                            addressLineTwo: $viewModel.addressLineTwo,
                            city: $viewModel.city,
                            state: $viewModel.state,
                            postalCode: $viewModel.postalCode,
                            language: $viewModel.language,
                            selectedBirthdate: Binding<Date>(
                                get: { viewModel.birthdate.dateFormatter().toDate() },
                                set: { newDate in viewModel.birthdate = newDate.toString() })
        )
    }

    @ViewBuilder
    var userProfile: some View {
        List {
            HStack {
                Circle()
                    .frame(width: 56, height: 56, alignment: .leading)
                    .foregroundStyle(.sky)
                    .overlay {
                        Text("AS")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.indigoBrand)
                    }
                VStack {
                    Text("\(viewModel.givenName) \(viewModel.familyName)")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.ink)

                    Text("Member profile")
                        .font(.system(size: 15))
                        .foregroundStyle(.muted)
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section("Personal") {
                ProfileListItemView(label: .Profile.birthdate,
                                    value: viewModel.birthdate.dateFormatter().toDate().toString())

                ProfileListItemView(label: .Profile.gender,
                                    value: viewModel.gender.displayName)

                ProfileListItemView(label: .Profile.language,
                                    value: viewModel.language)
            }

            Section("Contact") {
                ProfileListItemView(label: .Profile.email,
                                    value: viewModel.email)

                ProfileListItemView(label: .Profile.work,
                                    value: viewModel.workPhone)

                ProfileListItemView(label: .Profile.home,
                                    value: viewModel.homePhone)

                ProfileListItemView(label: .Profile.mobile,
                                    value: viewModel.mobilePhone)
            }

            Section("Address") {
                Text("\(viewModel.addressLineOne), \(viewModel.addressLineTwo)")
            }

            BWellButton(title: .Profile.signOut,
                        textColor: .alert,
                        buttonColor: .clear,
                        action: {
                Log.ui.debug("Sign out button pressed.")
            })
            .listRowInsets(EdgeInsets())
        }
    }
}

private struct ProfileListItemView: View {
    var label: LocalizedStringResource
    var value: String

    var body: some View {
        HStack {
            Text(label)

            Spacer()

            Text(value.isEmpty ? "Not set" : value)
        }
    }
}

#Preview {
    ProfileView(viewModel: AppContainer.preview.makeProfileViewModel())
}

