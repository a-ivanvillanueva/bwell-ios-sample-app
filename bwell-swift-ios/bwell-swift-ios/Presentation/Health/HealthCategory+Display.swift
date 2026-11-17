//
//  HealthCategory+Display.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 19-10-2026.
//

import Foundation
import SwiftUI

extension HealthCategory {
    var title: LocalizedStringResource {
        switch self {
        case .allergyIntolerance: .Health.allergies
        case .carePlan: .Health.carePlans
        case .condition: .Health.conditions
        case .encounter: .Health.encounters
        case .immunization: .Health.immunizations
        case .labs: .Health.labs
        case .medications: .Health.medications
        case .procedure: .Health.procedures
        case .vitalSigns: .Health.vitalSigns
        }
    }

    var icon: String {
        switch self {
        case .allergyIntolerance: "heart.text.square"
        case .carePlan: "list.clipboard"
        case .condition: "stethoscope"
        case .encounter: "document"
        case .immunization: "syringe"
        case .labs: "testtube.2"
        case .medications: "pills"
        case .procedure: "document"
        case .vitalSigns: "waveform.path.ecg"
        }
    }

    var iconColor: Color {
        switch self {
        case .allergyIntolerance: .alert
        case .carePlan: .indigoBrand
        case .condition: .alert
        case .encounter: .indigoBrand
        case .immunization: .success
        case .labs: .success
        case .medications: .success
        case .procedure: .indigoBrand
        case .vitalSigns: .alert
        }
    }
}
