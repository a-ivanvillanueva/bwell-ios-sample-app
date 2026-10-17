//
//  HealthRecord.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 16-10-2026.
//

import Foundation

struct HealthCode: Hashable {
    let system: String?
    let code: String?
}

struct HealthGroup: Identifiable, Hashable {
    let id: String
    let name: String?
    let date: String?
    let code: HealthCode
}

struct HealthRecord: Identifiable, Hashable {
    struct Detail: Hashable {
        enum Kind: Hashable {
            case text, date, stackedText
        }

        let label: String
        let content: String
        let kind: Kind
    }

    struct Note: Hashable {
        let text: String
        let date: String?
    }

    let id: String
    let title: String?
    let heading: String?
    let date: String?
    let value: String?
    let details: [Detail]
    let notes: [Note]
}
