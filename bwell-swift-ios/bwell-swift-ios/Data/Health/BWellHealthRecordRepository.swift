//
//  BWellHealthRecordRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 16-10-2026.
//

import Foundation
import BWellSDK

@MainActor
final class BWellHealthRecordRepository: HealthRecordRepository {    
    private let sdkManager: BWellSDKManager

    init(sdkManager: BWellSDKManager) {
        self.sdkManager = sdkManager
    }

    func summary() async throws -> [HealthCategory: Int] {
        let response = try await sdkManager.health().getHealthSummary()
        return Dictionary(response.resources.map { (HealthCategory(sdk: $0.category), $0.total) },
                          uniquingKeysWith: +)
    }

    func groups (in category: HealthCategory) async throws -> [HealthGroup] {
        let health = try sdkManager.health()
        let request = BWell.HealthDataGroupRequest(page: 0)

        switch category {
        case .allergyIntolerance:
            return try await health.getAllergyIntoleranceGroups(request).mapGroups {
                HealthGroup(id: $0.id, name: $0.name, coding: $0.coding, date: $0.recordedDate)
            }
        case .carePlan:
            return try await health.getCarePlanGroups(request).mapGroups {
                HealthGroup(id: $0.id, name: $0.name, coding: $0.coding, date: $0.period?.start)
            }
        case .condition:
            return try await health.getConditionGroups(request).mapGroups {
                HealthGroup(id: $0.id, name: $0.name, coding: $0.coding, date: $0.recordedDate)
            }
        case .encounter:
            return try await health.getEncounterGroups(request).mapGroups {
                HealthGroup(id: $0.id, name: $0.name, coding: $0.coding, date: $0.date)
            }
        case .immunization:
            return try await health.getImmunizationGroups(request).mapGroups {
                HealthGroup(id: $0.id, name: $0.name, coding: $0.coding, date: $0.occurrenceDateTime)
            }
        case .labs:
            return try await health.getLabGroups(request).mapGroups {
                HealthGroup(id: $0.id, name: $0.name, coding: $0.coding, date: $0.effectiveDateTime)
            }
        case .medication:
            return try await health.getMedicationGroups(request).mapGroups {
                HealthGroup(id: $0.id, name: $0.name, coding: $0.coding, date: $0.authoredOn)
            }
        case .procedure:
            return try await health.getProcedureGroups(request).mapGroups {
                HealthGroup(id: $0.id, name: $0.name, coding: $0.coding, date: $0.performedDate)
            }
        case .vitalSigns:
            return try await health.getVitalSignGroups(request).mapGroups {
                HealthGroup(id: $0.id, name: $0.name, coding: $0.coding, date: $0.effectiveDateTime)
            }
        }
    }

    func records(in category: HealthCategory, group: HealthGroup) async throws -> [HealthRecord] {
        let health = try sdkManager.health()
        var request = BWell.HealthDataRequest(page: 0)

        request.groupCode = BWell.SearchToken(value: BWell.SearchToken.Value(system: group.code.system, code: group.code.code))

        switch category {
        case .allergyIntolerance:
            return try await health.getAllergyIntolerances(request).items.map {
                HealthRecord(sdk: $0)
            }
        case .carePlan:
            return try await health.getCarePlans(request).items.map {
                HealthRecord(sdk: $0)
            }
        case .condition:
            return try await health.getConditions(request).items.map {
                HealthRecord(sdk: $0)
            }
        case .encounter:
            return try await health.getEncounters(request).items.map {
                HealthRecord(sdk: $0)
            }
        case .immunization:
            return try await health.getImmunizations(request).items.map {
                HealthRecord(sdk: $0)
            }
        case .labs:
            return try await health.getLabs(request).items.map {
                HealthRecord(sdk: $0)
            }
        case .medication:
            return try await health.getMedicationStatements(request).items.map {
                HealthRecord(sdk: $0)
            }
        case .procedure:
            return try await health.getProcedures(request).items.map {
                HealthRecord(sdk: $0)
            }
        case .vitalSigns:
            return try await health.getVitalSigns(request).items.map {
                HealthRecord(sdk: $0)
            }
        }
    }
}

// Unrwapping helpers.
private extension BWell.GroupResult {
    func mapGroups(_ transform: (Group) -> HealthGroup?) -> [HealthGroup] {
        return (resources ?? []).compactMap(transform)
    }
}

private extension BWell.ResourceBundle {
    var items: [Resource] {
        entry?.compactMap {
            $0.resource
        } ?? []
    }
}
