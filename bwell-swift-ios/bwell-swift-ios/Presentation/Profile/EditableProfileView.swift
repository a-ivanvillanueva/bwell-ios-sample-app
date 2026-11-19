//
//  EditableProfileView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 30/10/25.
//

import Foundation
import SwiftUI

struct EditableProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var shouldRotate: Bool = false

    // Personal Information
    @Binding var givenName: String
    @Binding var familyName: String
    @Binding var gender: Gender

    // Contact Information
    @Binding var email: String
    @Binding var workPhone: String
    @Binding var homePhone: String
    @Binding var mobilePhone: String

    // Address Information
    @Binding var addressLineOne: String
    @Binding var addressLineTwo: String
    @Binding var city: String
    @Binding var state: String
    @Binding var postalCode: String

    // Language
    @Binding var language: String

    // Birthdate
    @Binding var selectedBirthdate: Date

    var body: some View {
        List {
            Section("Personal") {
                EditProfileTextFieldView(fieldTitle: "First name", text: $givenName)
                EditProfileTextFieldView(fieldTitle: "Last name", text: $familyName)
                genderPickerView
                birthDateView
                EditProfileTextFieldView(fieldTitle: "Language", text: $language)
            }

            Section("Contact") {
                EditProfileTextFieldView(fieldTitle: "Email", text: $email)
                EditProfileTextFieldView(fieldTitle: "Work phone", text: $workPhone)
                EditProfileTextFieldView(fieldTitle: "Home name", text: $homePhone)
                EditProfileTextFieldView(fieldTitle: "Mobile name", text: $mobilePhone)
            }

            Section("Address") {
                EditProfileTextFieldView(fieldTitle: "Address Line 1", text: $addressLineOne)
                EditProfileTextFieldView(fieldTitle: "Address Line 2", text: $addressLineTwo)
                EditProfileTextFieldView(fieldTitle: "City", text: $city)
                EditProfileTextFieldView(fieldTitle: "Province or State", text: $state)
                EditProfileTextFieldView(fieldTitle: "Postal Code", text: $postalCode)
            }
        }
        .scrollContentBackground(.hidden)
        .background(.canvas)
    }

    @ViewBuilder
    var birthDateView: some View {
        HStack(alignment: .center) {
            Text("Birthdate")
                .foregroundStyle(.muted)
                .font(.system(size: 13))

            Spacer()

            DatePicker("",
                       selection: $selectedBirthdate,
                       in: ...Date(),
                       displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .tint(.action)
        }
    }

    @ViewBuilder
    var genderPickerView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Gender")
                .foregroundStyle(.muted)
                .font(.system(size: 13))

            HStack {
                Text("\(gender.displayName)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 17))
                    .foregroundStyle(.ink)

                Spacer()

                Menu {
                    GenderMenuButton(title: "Male",
                                     genderOption: .male,
                                     currentGender: gender) { gender = .male }

                    GenderMenuButton(title: "Female",
                                     genderOption: .female,
                                     currentGender: gender) { gender = .female }

                    GenderMenuButton(title: "Other",
                                     genderOption: .other,
                                     currentGender: gender) { gender = .other }
                } label: {
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.systemGray4))
                }
            }
        }
    }
}

private struct EditProfileTextFieldView: View {
    var fieldTitle: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(fieldTitle)
                .foregroundStyle(.muted)
                .font(.system(size: 13))

            HStack(alignment: .lastTextBaseline) {
                TextField("", text: $text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 17))
                    .foregroundStyle(.ink)

                Spacer()

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .rotationEffect(.degrees(45))
                            .foregroundStyle(Color(.systemGray4))
                            .frame(width: 10)
                    }
                }
            }
        }
    }
}

private struct GenderMenuButton: View {
    @Binding private var isSelected: Bool

    let title: String
    let genderOption: Gender
    let currentGender: Gender
    let action: () -> Void

    init(title: String, genderOption: Gender, currentGender: Gender, action: @escaping () -> Void) {
        self.title = title
        self.genderOption = genderOption
        self.currentGender = currentGender
        self.action = action
        _isSelected = Binding(
            get: { currentGender == genderOption },
            set: { newValue in
                if newValue {
                    action()
                }
            }
        )
    }

    var body: some View {
        Toggle(isOn: $isSelected) {
            Text(title)
                .foregroundStyle(.ink)
        }
    }
}
