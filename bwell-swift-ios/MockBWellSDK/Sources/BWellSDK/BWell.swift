//
//  BWell.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 10-10-2026.
//

import Foundation

/// Namespace for the mock SDK's types (mirrors how the app refers to `BWell.Something`).
///
/// This is a stand-in for b.well's private SDK. It has the same names and shapes the
/// sample app uses, but it returns fictional sample data and makes no network calls.
public enum BWell {}

// MARK: - Configuration & authentication

extension BWell {
    public enum LogLevel: Hashable {
        case none, error, warn, info, debug, verbose
    }

    /// Where the SDK keeps its tokens. The app supplies a Keychain-backed implementation.
    public protocol TokenStorage: AnyObject {
        func get(key: String) -> String?
        func get(key: String, completion: @escaping (String?) -> Void)
        func getMany(keys: [String]) -> [String: String?]
        func set(key: String, value: String)
        func setMany(keyValues: [String: String])
        func delete(key: String) -> Bool
    }

    public struct SDKConfig {
        public var clientKey: String
        public var logLevel: LogLevel
        public var tokenStorage: TokenStorage?

        public init(clientKey: String, logLevel: LogLevel = .none, tokenStorage: TokenStorage? = nil) {
            self.clientKey = clientKey
            self.logLevel = logLevel
            self.tokenStorage = tokenStorage
        }
    }

    public enum Credentials: Hashable {
        case emailPassword(email: String, password: String)
        case oauth(token: String)
    }

    public struct CreateConsentRequest: Hashable {
        public enum Status: Hashable { case active, inactive, draft }
        public enum Category: Hashable { case tos, hipaa, research }
        public struct Provision: Hashable {
            public enum Kind: Hashable { case permit, deny }
            public var type: Kind
            public init(type: Kind) { self.type = type }
        }

        public var status: Status
        public var provision: Provision
        public var category: Category

        public init(status: Status, provision: Provision, category: Category) {
            self.status = status
            self.provision = provision
            self.category = category
        }
    }
}

// MARK: - Shared FHIR-style building blocks

extension BWell {
    public struct Coding: Hashable {
        public var system: String?
        public var code: String?
        public var display: String?
    }

    public struct CodeableConcept: Hashable {
        public var id: String?
        public var coding: [Coding]?
        public var text: String?
    }

    public struct Narrative: Hashable {
        public var status: String?
        public var div: String?
    }

    public struct Period: Hashable {
        public var start: String?
        public var end: String?
    }

    public struct Annotation: Hashable {
        public var id: String?
        public var text: String?
        public var time: String?
    }

    public struct Dosage: Hashable {
        public var id: String?
        public var text: String?
    }

    /// A page of resources, wrapped the way the app unwraps it: `response.entry?.compactMap { $0.resource }`.
    public struct ResourceBundle<Resource> {
        public struct Entry {
            public var resource: Resource?
        }
        public var entry: [Entry]?
    }

    /// A list of group summaries, read as `response.resources`.
    public struct GroupResult<Group> {
        public var resources: [Group]?
    }
}

// MARK: - Health data requests

extension BWell {
    public struct SearchToken: Hashable {
        public struct Value: Hashable {
            public var system: String?
            public var code: String?
            public init(system: String?, code: String?) {
                self.system = system
                self.code = code
            }
        }
        public var value: Value
        public init(value: Value) { self.value = value }
    }

    public struct HealthDataRequest: Hashable {
        public var page: Int
        public var groupCode: SearchToken?
        public init(page: Int) { self.page = page }
    }

    public struct HealthDataGroupRequest: Hashable {
        public var page: Int
        public init(page: Int) { self.page = page }
    }
}

// MARK: - Health summary and resources

extension BWell {
    public struct HealthSummary: Hashable {
        public struct Resource: Hashable {
            public enum Category: Hashable {
                case allergyIntolerance, carePlan, condition, encounter, immunization
                case labs, medications, procedure, vitalSigns
            }
            public var category: Category
            public var total: Int
        }
        public var resources: [Resource]
    }

    public struct AllergyIntolerance: Hashable {
        public var id: String?
        public var code: CodeableConcept?
        public var criticality: String?
        public var onsetDateTime: String?
        public var text: Narrative?
    }

    public struct CarePlan: Hashable {
        public var id: String?
        public var title: String?
        public var period: Period?
        public var created: String?
        public var description: String?
        public var text: Narrative?
    }

    public struct Condition: Hashable {
        public var id: String?
        public var code: CodeableConcept?
        public var recordedDate: String?
        public var onsetDateTime: String?
        public var clinicalStatus: CodeableConcept?
        public var bodySite: [CodeableConcept]?
        public var note: [Annotation]?
    }

    public struct Encounter: Hashable {
        public struct Hospitalization: Hashable {
            public var dischargeDisposition: CodeableConcept?
        }
        public var id: String?
        public var text: Narrative?
        public var period: Period?
        public var status: String?
        public var `class`: Coding?
        public var hospitalization: Hospitalization?
    }

    public struct Immunization: Hashable {
        public var id: String?
        public var vaccineCode: CodeableConcept?
        public var occurrenceDateTime: String?
        public var expirationDate: String?
        public var route: CodeableConcept?
        public var text: Narrative?
    }

    /// Used for both labs and vital signs, as in the real SDK.
    public struct Observation: Hashable {
        public var id: String?
        public var code: CodeableConcept?
        public var effectiveDateTime: String?
        public var effectivePeriod: Period?
        public var text: Narrative?
        public var note: [Annotation]?
    }

    public struct Procedure: Hashable {
        public var id: String?
        public var code: CodeableConcept?
        public var performedDateTime: String?
        public var performedPeriod: Period?
        public var text: Narrative?
        public var note: [Annotation]?
    }

    public struct MedicationStatement: Hashable {
        public var id: String?
        public var medicationCodeableConcept: CodeableConcept?
        public var effectivePeriod: Period?
        public var status: String?
        public var reasonCode: [CodeableConcept]?
        public var dosage: [Dosage]?
    }
}

// MARK: - Health data groups

extension BWell {
    public struct AllergyIntoleranceGroup: Hashable {
        public var id: String?
        public var name: String?
        public var coding: Coding?
        public var recordedDate: String?
    }
    public struct CarePlanGroup: Hashable {
        public var id: String?
        public var name: String?
        public var coding: Coding?
        public var period: Period?
    }
    public struct ConditionGroup: Hashable {
        public var id: String?
        public var name: String?
        public var coding: Coding?
        public var recordedDate: String?
    }
    public struct EncounterGroup: Hashable {
        public var id: String?
        public var name: String?
        public var coding: Coding?
        public var date: String?
    }
    public struct ImmunizationGroup: Hashable {
        public var id: String?
        public var name: String?
        public var coding: Coding?
        public var occurrenceDateTime: String?
    }
    public struct LabGroups: Hashable {
        public var id: String?
        public var name: String?
        public var coding: Coding?
        public var effectiveDateTime: String?
    }
    public struct MedicationGroup: Hashable {
        public var id: String?
        public var name: String?
        public var coding: Coding?
        public var authoredOn: String?
    }
    public struct ProcedureGroups: Hashable {
        public var id: String?
        public var name: String?
        public var coding: Coding?
        public var performedDate: String?
    }
    public struct VitalSignGroups: Hashable {
        public var id: String?
        public var name: String?
        public var coding: Coding?
        public var effectiveDateTime: String?
    }
}

// MARK: - User profile

extension BWell {
    public enum Gender: Hashable { case female, male, other, unknown }

    public struct HumanName: Hashable {
        public var family: String?
        public var given: [String]?
        public init(family: String?, given: [String]?) {
            self.family = family
            self.given = given
        }
    }

    public struct Address: Hashable {
        public var line: [String]?
        public var city: String?
        public var state: String?
        public var postalCode: String?
        public var country: String?
    }

    public struct ContactPoint: Hashable {
        public var use: String?
        public var value: String?
    }

    public struct GetUserProfileResult: Hashable {
        public var name: [HumanName]?
        public var address: [Address]?
        public var gender: Gender?
        public var birthdate: String?
        public var language: String?
        public var telecom: [ContactPoint]?
    }

    public struct UpdateUserProfileRequest: Hashable {
        public var name: HumanName?
        public var addressStreet: String?
        public var addressUnit: String?
        public var city: String?
        public var stateOrProvidence: String?
        public var postageOrZipCode: String?
        public var birthDate: String?
        public var gender: Gender?
        public var language: String?

        public init(name: HumanName?, addressStreet: String?, addressUnit: String?, city: String?,
                    stateOrProvidence: String?, postageOrZipCode: String?, birthDate: String?,
                    gender: Gender?, language: String?) {
            self.name = name
            self.addressStreet = addressStreet
            self.addressUnit = addressUnit
            self.city = city
            self.stateOrProvidence = stateOrProvidence
            self.postageOrZipCode = postageOrZipCode
            self.birthDate = birthDate
            self.gender = gender
            self.language = language
        }
    }
}

// MARK: - Connections and search

extension BWell {
    public enum DataConnectionStatus: Hashable {
        case connected, disconnected, deleted, expired, accessEnded, error, unknown
    }

    public struct MemberConnectionResult: Hashable {
        public var id: String
        public var name: String
        public var status: DataConnectionStatus
    }

    public struct ConnectionStatusResult: Hashable {
        public var status: DataConnectionStatus?
        public var statusUpdated: Bool
    }

    public struct DeleteConnectionRequest: Hashable {
        public var connectionId: String
        public init(connectionId: String) { self.connectionId = connectionId }
    }

    public struct DisconnectConnectionRequest: Hashable {
        public var connectionId: String
        public init(connectionId: String) { self.connectionId = connectionId }
    }

    public struct CreateConnectionRequest: Hashable {
        public var connectionId: String
        public var username: String
        public var password: String
        public init(connectionId: String, username: String, password: String) {
            self.connectionId = connectionId
            self.username = username
            self.password = password
        }
    }

    public struct CreateConnectionResult: Hashable {
        public var connectionId: String
    }

    public struct DataSourceRequest: Hashable {
        public var connectionId: String
        public init(connectionId: String) { self.connectionId = connectionId }
    }

    public struct DataSourceResult: Hashable {
        public var connectionId: String
    }

    public struct OAuthURLRequest: Hashable {
        public var connectionId: String
        public init(connectionId: String) { self.connectionId = connectionId }
    }

    public struct OAuthURLResult: Hashable {
        public var redirectURL: String
    }

    public struct SearchHealthResourcesRequest: Hashable {
        public struct Filter: Hashable {
            public var includePopulatedProaOnly: Bool
            public init(includePopulatedProaOnly: Bool) { self.includePopulatedProaOnly = includePopulatedProaOnly }
        }
        public struct OrderBy: Hashable {
            public enum Field: Hashable { case distance, name }
            public enum Order: Hashable { case asc, desc }
            public var field: Field
            public var order: Order
            public init(field: Field, order: Order) {
                self.field = field
                self.order = order
            }
        }
        public struct Location: Hashable {
            public var latitude: Double
            public var longitude: Double
            public init(latitude: Double, longitude: Double) {
                self.latitude = latitude
                self.longitude = longitude
            }
        }

        public var page: Int
        public var pageSize: Int
        public var search: String?
        public var filters: Filter?
        public var orderBy: [OrderBy]?
        public var location: Location?

        public init(page: Int, pageSize: Int, search: String?, filters: Filter?,
                    orderBy: [OrderBy]?, location: Location?) {
            self.page = page
            self.pageSize = pageSize
            self.search = search
            self.filters = filters
            self.orderBy = orderBy
            self.location = location
        }
    }

    public struct SearchHealthResourcesResults: Hashable {
        public struct Endpoint: Hashable {
            public var name: String?
        }
        public struct Result: Hashable {
            public var id: String?
            public var content: String?
            public var endpoint: [Endpoint]?
        }
        public var results: [Result]?
    }
}
