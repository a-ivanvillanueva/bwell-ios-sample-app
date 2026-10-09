//
//  SampleData.swift
//  BWellSDK
//
//  Created by Ivan Villanueva on 09-10-2026.
//

import Foundation

/// Fictional sample data. None of this describes a real person.
enum SampleData {
    // MARK: Building blocks

    static let codeSystem = "https://example.org/sample-codes"

    struct GroupDef<Item> {
        let code: String
        let name: String
        let date: String
        let items: [Item]

        var groupId: String { "group-\(code)" }
        var coding: BWell.Coding { SampleData.coding(code, name) }
    }

    static func coding(_ code: String, _ display: String) -> BWell.Coding {
        BWell.Coding(system: codeSystem, code: code, display: display)
    }
    static func concept(_ text: String) -> BWell.CodeableConcept {
        BWell.CodeableConcept(id: nil, coding: [coding(text.lowercased(), text)], text: text)
    }
    static func narrative(_ text: String) -> BWell.Narrative {
        BWell.Narrative(status: "generated", div: "<div><p>\(text)</p></div>")
    }
    static func period(_ start: String, _ end: String? = nil) -> BWell.Period {
        BWell.Period(start: start, end: end)
    }
    static func note(_ id: String, _ text: String, _ time: String) -> BWell.Annotation {
        BWell.Annotation(id: id, text: text, time: time)
    }

    /// Returns the items of the group the request asks for (matched on the group code).
    static func bundle<Item>(_ groups: [GroupDef<Item>],
                                       for request: BWell.HealthDataRequest) -> BWell.ResourceBundle<Item> {
        let wanted = request.groupCode?.value.code
        let items = groups.first(where: { $0.code == wanted })?.items ?? []
        return .init(entry: items.map { BWell.ResourceBundle<Item>.Entry(resource: $0) })
    }

    // MARK: Profile

    static let profile = BWell.GetUserProfileResult(
        name: [BWell.HumanName(family: "Sample", given: ["Alex"])],
        address: [BWell.Address(line: ["123 Sample Street", "Apt 4"], city: "Toronto", state: "Ontario",
                                postalCode: "M5V 0A0", country: "Canada")],
        gender: .other,
        birthdate: "1990-01-01",
        language: "English",
        telecom: [BWell.ContactPoint(use: "email", value: "alex.sample@example.org"),
                  BWell.ContactPoint(use: "mobile", value: "555-0100"),
                  BWell.ContactPoint(use: "home", value: "555-0101"),
                  BWell.ContactPoint(use: "work", value: "555-0102")])

    // MARK: Connections and search

    static let memberConnections: [BWell.MemberConnectionResult] = [
        .init(id: "sample-health-system", name: "Sample Health System", status: .connected),
        .init(id: "sample-regional-lab", name: "Sample Regional Lab", status: .connected),
        .init(id: "sample-clinic", name: "Sample Family Clinic", status: .disconnected)
    ]

    static let healthResources: [BWell.SearchHealthResourcesResults.Result] = [
        "Sample Health System", "Sample Regional Lab", "Sample Family Clinic",
        "Example Community Hospital", "Demo Pharmacy Network", "Illustrative Imaging Center"
    ].enumerated().map { index, name in
        BWell.SearchHealthResourcesResults.Result(
            id: "resource-\(index + 1)", content: name,
            endpoint: [BWell.SearchHealthResourcesResults.Endpoint(name: "sample_endpoint_\(index + 1)")])
    }

    // MARK: Summary

    static var summary: [BWell.HealthSummary.Resource] {
        func total<Item>(_ groups: [GroupDef<Item>]) -> Int { groups.reduce(0) { $0 + $1.items.count } }
        return [
            .init(category: .allergyIntolerance, total: total(allergies)),
            .init(category: .carePlan, total: total(carePlans)),
            .init(category: .condition, total: total(conditions)),
            .init(category: .encounter, total: total(encounters)),
            .init(category: .immunization, total: total(immunizations)),
            .init(category: .labs, total: total(labs)),
            .init(category: .medications, total: total(medications)),
            .init(category: .procedure, total: total(procedures)),
            .init(category: .vitalSigns, total: total(vitalSigns))
        ]
    }

    // MARK: Health data

    static let allergies: [GroupDef<BWell.AllergyIntolerance>] = [
        GroupDef(code: "allergy-pollen", name: "Pollen", date: "2022-09-20", items: [
            BWell.AllergyIntolerance(id: "allergy-1", code: concept("Environmental"), criticality: "low",
                                     onsetDateTime: "2022-09-20", text: narrative("Seasonal sneezing and itchy eyes."))]),
        GroupDef(code: "allergy-penicillin", name: "Penicillin", date: "2019-04-02", items: [
            BWell.AllergyIntolerance(id: "allergy-2", code: concept("Medication"), criticality: "high",
                                     onsetDateTime: "2019-04-02", text: narrative("Rash reported after a course of antibiotics."))])
    ]

    static let carePlans: [GroupDef<BWell.CarePlan>] = [
        GroupDef(code: "careplan-wellness", name: "Annual wellness plan", date: "2024-01-15", items: [
            BWell.CarePlan(id: "plan-1", title: "Annual wellness plan", period: period("2024-01-15", "2025-01-14"), created: "2020-01-15",
                           description: "Yearly check-in with routine screenings.", text: narrative("Sample plan: routine screenings and a lifestyle review."))]),
        GroupDef(code: "careplan-bp", name: "Blood pressure monitoring", date: "2024-03-12", items: [
            BWell.CarePlan(id: "plan-2", title: "Blood pressure monitoring", period: period("2024-03-12"), created: "2020-01-15",
                           description: "Track home readings between visits.", text: narrative("Sample plan: record readings twice a week."))])
    ]

    static let conditions: [GroupDef<BWell.Condition>] = [
        GroupDef(code: "cond-hypertension", name: "Hypertension", date: "2024-03-12", items: [
            BWell.Condition(id: "cond-1", code: concept("Hypertension"), recordedDate: "2024-03-12", onsetDateTime: "2021-06-01",
                            clinicalStatus: concept("Active"), bodySite: nil,
                            note: [note("note-1", "Sample note: reviewed at annual visit.", "2024-03-12")])]),
        GroupDef(code: "cond-diabetes", name: "Type 2 diabetes mellitus", date: "2023-01-03", items: [
            BWell.Condition(id: "cond-2", code: concept("Type 2 diabetes mellitus"), recordedDate: "2023-01-03", onsetDateTime: "2022-11-10",
                            clinicalStatus: concept("Active"), bodySite: nil, note: nil)]),
        GroupDef(code: "cond-rhinitis", name: "Seasonal allergic rhinitis", date: "2022-09-20", items: [
            BWell.Condition(id: "cond-3", code: concept("Seasonal allergic rhinitis"), recordedDate: "2022-09-20", onsetDateTime: "2018-04-15",
                            clinicalStatus: concept("Active"), bodySite: [concept("Nasal cavity")], note: nil)]),
        GroupDef(code: "cond-back-pain", name: "Low back pain", date: "2020-02-14", items: [
            BWell.Condition(id: "cond-4", code: concept("Low back pain"), recordedDate: "2020-02-14", onsetDateTime: "2020-02-01",
                            clinicalStatus: concept("Resolved"), bodySite: [concept("Lumbar region")], note: nil)])
    ]

    static let encounters: [GroupDef<BWell.Encounter>] = [
        GroupDef(code: "enc-office", name: "Office visit", date: "2024-03-12", items: [
            BWell.Encounter(id: "enc-1", text: narrative("Routine office visit."), period: period("2024-03-12T09:00:00Z", "2024-03-12T09:30:00Z"),
                            status: "finished", class: coding("AMB", "Ambulatory"),
                            hospitalization: .init(dischargeDisposition: concept("Home")))]),
        GroupDef(code: "enc-lab", name: "Lab visit", date: "2023-01-03", items: [
            BWell.Encounter(id: "enc-2", text: narrative("Fasting blood draw."), period: period("2023-01-03T08:00:00Z", "2023-01-03T08:15:00Z"),
                            status: "finished", class: coding("AMB", "Ambulatory"), hospitalization: nil)])
    ]

    static let immunizations: [GroupDef<BWell.Immunization>] = [
        GroupDef(code: "imm-flu", name: "Influenza vaccine", date: "2023-10-05", items: [
            BWell.Immunization(id: "imm-1", vaccineCode: concept("Influenza vaccine"), occurrenceDateTime: "2023-10-05", expirationDate: "2027-10-12", route: concept("Intramuscular"), text: narrative("Seasonal flu shot."))]),
        GroupDef(code: "imm-tdap", name: "Tdap vaccine", date: "2021-05-18", items: [
            BWell.Immunization(id: "imm-2", vaccineCode: concept("Tdap vaccine"), occurrenceDateTime: "2021-05-18",
                               route: concept("Intramuscular"), text: narrative("Tetanus, diphtheria and pertussis booster."))])
    ]

    static let labs: [GroupDef<BWell.Observation>] = [
        GroupDef(code: "lab-a1c", name: "Hemoglobin A1c", date: "2024-02-20", items: [
            BWell.Observation(id: "lab-1", code: concept("Hemoglobin A1c"), effectiveDateTime: "2024-02-20", effectivePeriod: nil,
                              text: narrative("Sample result: 6.8 %."), note: [note("lab-note-1", "Sample note: fasting sample.", "2024-02-20")])]),
        GroupDef(code: "lab-lipids", name: "Lipid panel", date: "2023-01-03", items: [
            BWell.Observation(id: "lab-2", code: concept("Lipid panel"), effectiveDateTime: "2023-01-03", effectivePeriod: nil,
                              text: narrative("Sample result: within the sample reference range."), note: nil)])
    ]

    static let medications: [GroupDef<BWell.MedicationStatement>] = [
        GroupDef(code: "med-metformin", name: "Metformin", date: "2023-01-10", items: [
            BWell.MedicationStatement(id: "med-1", medicationCodeableConcept: concept("Metformin 500 mg tablet"),
                                      effectivePeriod: period("2023-01-10"), status: "active",
                                      reasonCode: [concept("Type 2 diabetes mellitus")],
                                      dosage: [BWell.Dosage(id: "dose-1", text: "One tablet by mouth twice daily")])]),
        GroupDef(code: "med-lisinopril", name: "Lisinopril", date: "2021-06-15", items: [
            BWell.MedicationStatement(id: "med-2", medicationCodeableConcept: concept("Lisinopril 10 mg tablet"),
                                      effectivePeriod: period("2021-06-15"), status: "active",
                                      reasonCode: [concept("Hypertension")],
                                      dosage: [BWell.Dosage(id: "dose-2", text: "One tablet by mouth once daily")])])
    ]

    static let procedures: [GroupDef<BWell.Procedure>] = [
        GroupDef(code: "proc-colonoscopy", name: "Screening colonoscopy", date: "2022-08-09", items: [
            BWell.Procedure(id: "proc-1", code: concept("Screening colonoscopy"), performedDateTime: "2022-08-09", performedPeriod: nil,
                            text: narrative("Routine screening procedure."), note: nil)]),
        GroupDef(code: "proc-xray", name: "Chest X-ray", date: "2020-02-14", items: [
            BWell.Procedure(id: "proc-2", code: concept("Chest X-ray"), performedDateTime: "2020-02-14", performedPeriod: nil,
                            text: narrative("Imaging study."), note: [note("proc-note-1", "Sample note: no acute findings.", "2020-02-14")])])
    ]

    static let vitalSigns: [GroupDef<BWell.Observation>] = [
        GroupDef(code: "vital-bp", name: "Blood pressure", date: "2024-03-12", items: [
            BWell.Observation(id: "vital-1", code: concept("Blood pressure"), effectiveDateTime: "2024-03-12", effectivePeriod: nil,
                              text: narrative("Sample reading: 128/82 mmHg."), note: nil)]),
        GroupDef(code: "vital-weight", name: "Body weight", date: "2024-03-12", items: [
            BWell.Observation(id: "vital-2", code: concept("Body weight"), effectiveDateTime: "2024-03-12", effectivePeriod: nil,
                              text: narrative("Sample reading: 72 kg."), note: nil)])
    ]
}
