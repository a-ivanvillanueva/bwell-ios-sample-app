//
//  Gender+Display.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import Foundation

extension Gender {
    var displayName: String {
        switch self {
        case .female: "Female"
        case .male: "Male"
        case .other: "Other"
        case .unknown: "Unknown"
        }
    }
}
