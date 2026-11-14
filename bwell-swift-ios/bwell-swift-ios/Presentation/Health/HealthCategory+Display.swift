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
        case .allergyIntolerance: LocalizedStringResource.Health.allergies
        case .carePlan: LocalizedStringResource.Health.carePlans
        case .condition: LocalizedStringResource.Health.conditions
        case .encounter: LocalizedStringResource.Health.encounters
        case .immunization: LocalizedStringResource.Health.immunizations
        case .labs: LocalizedStringResource.Health.labs
        case .medications: LocalizedStringResource.Health.medications
        case .procedure: LocalizedStringResource.Health.procedures
        case .vitalSigns: LocalizedStringResource.Health.vitalSigns
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
