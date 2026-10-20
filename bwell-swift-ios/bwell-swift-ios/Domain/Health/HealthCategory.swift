//
//  HealthCategory.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 16-10-2026.
//

import Foundation

enum HealthCategory: CaseIterable, Hashable, Identifiable {
    case allergyIntolerance, carePlan, condition, encounter, immunization
    case labs, medications, procedure, vitalSigns

    var id: Self { self }
}
