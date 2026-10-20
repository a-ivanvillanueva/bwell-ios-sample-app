//
//  HealthCategory+Display.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 19-10-2026.
//

import Foundation

extension HealthCategory {
    var title: String {
        switch self {
        case .allergyIntolerance: "Allergy Intolerances"
        case .carePlan: "Care Plans"
        case .condition: "Conditions"
        case .encounter: "Encounters"
        case .immunization: "Immunizations"
        case .labs: "Labs"
        case .medications: "Medications"
        case .procedure: "Procedures"
        case .vitalSigns: "Vital Signs"
        }
    }

    var icon: String {
            switch self {
            case .allergyIntolerance: "facemask"
            case .carePlan: "list.clipboard"
            case .condition: "stethoscope"
            case .encounter: "person.2.wave.2"
            case .immunization: "syringe"
            case .labs: "testtube.2"
            case .medications: "pills"
            case .procedure: "ivfluid.bag"
            case .vitalSigns: "waveform.path.ecg.rectangle"
            }
        }
}
