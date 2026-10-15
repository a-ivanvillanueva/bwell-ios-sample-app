//
//  SideMenuModel.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 28/10/25.
//

import Foundation

enum SideMenuModel: Int, CaseIterable {
    case home
    case profile
    case manageConnections
    case healthSummary
    case logout


    var title: String {
        switch self {
            case .home: "Home"
            case .profile: "Profile"
            case .manageConnections: "Manage Connections"
            case .healthSummary: "Health Summary"
            case .logout: "Logout"
        }
    }

    var iconName: String {
        switch self {
            case .home: "house"
            case .profile: "person"
            case .manageConnections: "rectangle.connected.to.line.below"
            case .healthSummary: "heart.text.clipboard"
            case .logout: "arrow.right.square"
        }
    }

    var destination: AppView {
        switch self {
            case .home: .home
            case .profile: .profile
            case .manageConnections: .manageConnections
            case .healthSummary: .healthSummary
            case .logout: .home
        }
    }
}

extension SideMenuModel: Identifiable {
    var id: Int {
        return self.rawValue
    }
}
