//
//  HealthRecord+BWell.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 16-10-2026.
//

import Foundation
import BWellSDK

extension HealthRecord.Detail {
    static func plain(_ label: String, _ content: String?) -> Self? {
        Self(label, content, .text)
    }

    static func dated(_ label: String, _ content: String?) -> Self? {
        Self(label, content, .date)
    }

    static func stacked(_ label: String, _ content: String?) -> Self? {
        Self(label, content, .stackedText)
    }

    private init?(_ label: String, _ content: String?, _ kind: Kind) {
        guard let content, !content.isEmpty else {
            return nil
        }
        self.init(label: label, content: content, kind: kind)
    }
}

extension HealthRecord.Note {
    init(sdk annotation: BWell.Annotation) {
        self.init(text: annotation.text ?? "Note not available", date: annotation.time)
    }
}

private extension HealthRecord {
    init(sdkId: String?,
         title: String?,
         heading: String? = nil,
         date: String? = nil,
         value: String? = nil,
         details: [Detail?],
         notes: [BWell.Annotation]? = nil) {

        self.init(id: sdkId ?? UUID().uuidString,
                  title: title,
                  heading: heading ?? title,
                  date: date,
                  value: value,
                  details: details.compactMap { $0 },
                  notes: (notes ?? []).map { Note(sdk: $0) })
    }
}

extension HealthRecord {
    init(sdk allergy: BWell.AllergyIntolerance) {
        self.init(sdkId: allergy.id,
                  title: allergy.code?.coding?.first?.display,
                  value: allergy.criticality,
                  details: [
                    .stacked("Category: ", allergy.code?.text?.capitalizingFirstLetter()),
                    .dated("Date of last occurrence: ", allergy.onsetDateTime),
                    .stacked("Summary: ", allergy.text?.div?.stripHTML())
                  ])
    }

    init(sdk carePlan: BWell.CarePlan) {
            self.init(sdkId: carePlan.id,
                      title: carePlan.title,
                      date: carePlan.period?.start,
                      details: [
                        .dated("Plan created in: ", carePlan.created),
                        .dated("Plan start date: ", carePlan.period?.start),
                        .dated("Plan end date: ", carePlan.period?.end),
                        .plain("Description: ", carePlan.description),
                        .stacked("Summary: ", carePlan.text?.div?.stripHTML())
                      ])
        }

        init(sdk condition: BWell.Condition) {
            var details: [Detail?] = [
                .dated("Onset date: ", condition.onsetDateTime),
                .dated("Recorded date: ", condition.recordedDate),
                .plain("Clinical status: ", condition.clinicalStatus?.text),
                .plain("Summary: ", condition.code?.text)
            ]
            details += (condition.bodySite ?? []).map { Detail.plain("Body site: ", $0.coding?.first?.display) }

            self.init(sdkId: condition.id,
                      title: condition.code?.text,
                      date: condition.recordedDate,
                      details: details,
                      notes: condition.note)
        }

        init(sdk encounter: BWell.Encounter) {
            self.init(sdkId: encounter.id,
                      title: encounter.text?.status,
                      heading: encounter.text?.div?.stripHTML(),
                      date: encounter.period?.start,
                      details: [
                        .dated("Encounter start: ", encounter.period?.start),
                        .dated("Encounter end: ", encounter.period?.end),
                        .plain("Status: ", encounter.status),
                        .plain("Class: ", encounter.class?.display),
                        .plain("Hospitalization: ", encounter.hospitalization?.dischargeDisposition?.text),
                        .plain("Summary: ", encounter.text?.div?.stripHTML())
                      ])
        }

        init(sdk immunization: BWell.Immunization) {
            self.init(sdkId: immunization.id,
                      title: immunization.vaccineCode?.text,
                      date: immunization.occurrenceDateTime,
                      details: [
                        .dated("Occurrence date: ", immunization.occurrenceDateTime),
                        .dated("Expiration date: ", immunization.expirationDate),
                        .plain("Administration route: ", immunization.route?.text),
                        .plain("Summary: ", immunization.text?.div?.stripHTML())
                      ])
        }

        /// Used for both labs and vital signs: the SDK uses one type for both.
        init(sdk observation: BWell.Observation) {
            self.init(sdkId: observation.id,
                      title: observation.code?.text,
                      date: observation.effectiveDateTime,
                      details: [
                        .dated("Effective date: ", observation.effectiveDateTime),
                        .plain("Effective period: ", observation.effectivePeriod?.start),
                        .plain("Summary: ", observation.text?.div?.stripHTML())
                      ],
                      notes: observation.note)
        }

        init(sdk procedure: BWell.Procedure) {
            self.init(sdkId: procedure.id,
                      title: procedure.code?.text,
                      date: procedure.performedDateTime,
                      details: [
                        .dated("Performed date: ", procedure.performedDateTime),
                        .plain("Performed period: ", procedure.performedPeriod?.start),
                        .plain("Summary: ", procedure.text?.div?.stripHTML())
                      ],
                      notes: procedure.note)
        }

        init(sdk medication: BWell.MedicationStatement) {
            var details: [Detail?] = [
                .dated("Period start: ", medication.effectivePeriod?.start),
                .dated("Period end: ", medication.effectivePeriod?.end),
                .plain("Status: ", medication.status)
            ]
            details += (medication.reasonCode ?? []).map { Detail.plain("Reason for medication: ", $0.text) }
            details += (medication.dosage ?? []).map { Detail.plain("Dosage: ", $0.text) }

            self.init(sdkId: medication.id,
                      title: medication.medicationCodeableConcept?.text,
                      date: medication.effectivePeriod?.start,
                      details: details)
        }
}

extension HealthGroup {
    init?(id: String?, name: String?, coding: BWell.Coding?, date: String?) {
        guard let id, let coding else {
            return nil
        }

        self.init(id: id,
                  name: name,
                  date: date,
                  code: HealthCode(system: coding.system, code: coding.code))
    }
}

extension HealthCategory {
    init(sdk category: BWell.HealthSummary.Resource.Category) {
        switch category {
        case .allergyIntolerance: self = .allergyIntolerance
        case .carePlan: self = .carePlan
        case .condition: self = .condition
        case .encounter: self = .encounter
        case .immunization: self = .immunization
        case .labs: self = .labs
        case .medications: self = .medications
        case .procedure: self = .procedure
        case .vitalSigns: self = .vitalSigns
        }
    }
}
