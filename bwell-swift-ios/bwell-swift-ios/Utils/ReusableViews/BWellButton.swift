//
//  BWellButton.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 28/10/25.
//
import Foundation
import SwiftUI

struct BWellButton: View {
    let title: String
    var textColor: Color = .white
    var buttonColor: Color = .action
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(buttonColor)
        .foregroundColor(.white)
        .cornerRadius(14)
        .disabled(isLoading)
    }
}

#Preview {
    BWellButton(title: "Sign in") {
        debugPrint("Button pressed")
    }.padding(.horizontal)
}
