//
//  BWellSDK.swift
//  BWellSDK
//
//  Created by Ivan Villanueva on 09-10-2026.
//

import Foundation

public enum MockSDKError: Error, LocalizedError {
    case invalidClientKey
    case invalidCredentials
    case notAuthenticated

    public var errorDescription: String? {
        switch self {
        case .invalidClientKey: "The (mock) client key was empty."
        case .invalidCredentials: "The (mock) credentials were empty."
        case .notAuthenticated: "No active (mock) session."
        }
    }
}

/// Entry point of the mock SDK. Any non-empty client key and any non-empty credentials work.
/// A "session" is just a flag stored through the app's `TokenStorage`, so logging in survives
/// relaunches and logging out (which clears the Keychain) returns to the login screen.
public final class BWellSDK {
    static let sessionKey = "mock.session"

    public let user: UserManager
    public let health: HealthDataManager
    public let connection: ConnectionManager
    public let device: DeviceManager
    public let search: SearchManager

    private let config: BWell.SDKConfig

    public init(config: BWell.SDKConfig) throws {
        guard !config.clientKey.isEmpty else { throw MockSDKError.invalidClientKey }

        self.config = config
        let storage = config.tokenStorage
        let isAuthenticated: () -> Bool = { storage?.get(key: BWellSDK.sessionKey) != nil }

        self.user = UserManager(isAuthenticated: isAuthenticated)
        self.health = HealthDataManager()
        self.connection = ConnectionManager()
        self.device = DeviceManager()
        self.search = SearchManager()
    }

    public func initialize() async throws {
        try? await Task.sleep(nanoseconds: 300_000_000)
    }

    public func authenticate(credentials: BWell.Credentials) async throws {
        try? await Task.sleep(nanoseconds: 400_000_000)

        switch credentials {
        case let .emailPassword(email, password):
            guard !email.isEmpty, !password.isEmpty else { throw MockSDKError.invalidCredentials }
            user.setEmail(email)
        case let .oauth(token):
            guard !token.isEmpty else { throw MockSDKError.invalidCredentials }
        }

        config.tokenStorage?.set(key: BWellSDK.sessionKey, value: "active")
    }
}

// MARK: - Managers

public final class UserManager {
    private let isAuthenticated: () -> Bool
    private var profile = SampleData.profile

    init(isAuthenticated: @escaping () -> Bool) {
        self.isAuthenticated = isAuthenticated
    }

    func setEmail(_ email: String) {
        var telecom = profile.telecom ?? []
        telecom.removeAll { $0.use == "email" }
        telecom.insert(BWell.ContactPoint(use: "email", value: email), at: 0)
        profile.telecom = telecom
    }

    public func getProfile() async throws -> BWell.GetUserProfileResult? {
        guard isAuthenticated() else { throw MockSDKError.notAuthenticated }
        return profile
    }

    public func createConsent(_ request: BWell.CreateConsentRequest) async throws -> Bool {
        guard isAuthenticated() else { throw MockSDKError.notAuthenticated }
        return true
    }

    public func updateProfile(_ request: BWell.UpdateUserProfileRequest) async throws -> Bool {
        guard isAuthenticated() else { throw MockSDKError.notAuthenticated }

        profile.name = request.name.map { [$0] }
        profile.address = [BWell.Address(line: [request.addressStreet, request.addressUnit].compactMap { $0 },
                                         city: request.city,
                                         state: request.stateOrProvidence,
                                         postalCode: request.postageOrZipCode,
                                         country: profile.address?.first?.country)]
        profile.birthdate = request.birthDate
        profile.gender = request.gender
        profile.language = request.language
        return true
    }
}

public final class ConnectionManager {
    private var connections = SampleData.memberConnections

    public func getMemberConnections() async throws -> [BWell.MemberConnectionResult] {
        connections
    }

    public func deleteConnection(_ request: BWell.DeleteConnectionRequest) async throws -> BWell.ConnectionStatusResult {
        let existed = connections.contains { $0.id == request.connectionId }
        connections.removeAll { $0.id == request.connectionId }
        return .init(status: .deleted, statusUpdated: existed)
    }

    public func disconnectConnection(_ request: BWell.DisconnectConnectionRequest) async throws -> BWell.ConnectionStatusResult {
        guard let index = connections.firstIndex(where: { $0.id == request.connectionId }) else {
            return .init(status: nil, statusUpdated: false)
        }
        connections[index].status = .disconnected
        return .init(status: .disconnected, statusUpdated: true)
    }

    public func createConnection(_ request: BWell.CreateConnectionRequest) async throws -> BWell.CreateConnectionResult {
        if !connections.contains(where: { $0.id == request.connectionId }) {
            connections.append(.init(id: request.connectionId, name: "Sample Provider (\(request.connectionId))", status: .connected))
        }
        return .init(connectionId: request.connectionId)
    }

    public func getDataSource(_ request: BWell.DataSourceRequest) async throws -> BWell.DataSourceResult {
        .init(connectionId: request.connectionId)
    }

    public func getOAuthURL(_ request: BWell.OAuthURLRequest) async throws -> BWell.OAuthURLResult {
        .init(redirectURL: "https://example.org/?status_code=success")
    }
}

public final class SearchManager {
    public func searchHealthResources(_ request: BWell.SearchHealthResourcesRequest) async throws -> BWell.SearchHealthResourcesResults {
        let query = request.search?.trimmingCharacters(in: .whitespaces) ?? ""
        let all = SampleData.healthResources
        let matches = query.isEmpty ? all : all.filter { ($0.content ?? "").localizedCaseInsensitiveContains(query) }
        return .init(results: matches)
    }
}

public final class DeviceManager {}

public final class HealthDataManager {
    public func getHealthSummary() async throws -> BWell.HealthSummary {
        .init(resources: SampleData.summary)
    }

    // MARK: Allergy intolerances
    public func getAllergyIntoleranceGroups(_ request: BWell.HealthDataGroupRequest) async throws -> BWell.GroupResult<BWell.AllergyIntoleranceGroup> {
        .init(resources: SampleData.allergies.map {
            BWell.AllergyIntoleranceGroup(id: $0.groupId, name: $0.name, coding: $0.coding, recordedDate: $0.date)
        })
    }
    public func getAllergyIntolerances(_ request: BWell.HealthDataRequest) async throws -> BWell.ResourceBundle<BWell.AllergyIntolerance> {
        SampleData.bundle(SampleData.allergies, for: request)
    }

    // MARK: Care plans
    public func getCarePlanGroups(_ request: BWell.HealthDataGroupRequest) async throws -> BWell.GroupResult<BWell.CarePlanGroup> {
        .init(resources: SampleData.carePlans.map {
            BWell.CarePlanGroup(id: $0.groupId, name: $0.name, coding: $0.coding, period: SampleData.period($0.date))
        })
    }
    public func getCarePlans(_ request: BWell.HealthDataRequest) async throws -> BWell.ResourceBundle<BWell.CarePlan> {
        SampleData.bundle(SampleData.carePlans, for: request)
    }

    // MARK: Conditions
    public func getConditionGroups(_ request: BWell.HealthDataGroupRequest) async throws -> BWell.GroupResult<BWell.ConditionGroup> {
        .init(resources: SampleData.conditions.map {
            BWell.ConditionGroup(id: $0.groupId, name: $0.name, coding: $0.coding, recordedDate: $0.date)
        })
    }
    public func getConditions(_ request: BWell.HealthDataRequest) async throws -> BWell.ResourceBundle<BWell.Condition> {
        SampleData.bundle(SampleData.conditions, for: request)
    }

    // MARK: Encounters
    public func getEncounterGroups(_ request: BWell.HealthDataGroupRequest) async throws -> BWell.GroupResult<BWell.EncounterGroup> {
        .init(resources: SampleData.encounters.map {
            BWell.EncounterGroup(id: $0.groupId, name: $0.name, coding: $0.coding, date: $0.date)
        })
    }
    public func getEncounters(_ request: BWell.HealthDataRequest) async throws -> BWell.ResourceBundle<BWell.Encounter> {
        SampleData.bundle(SampleData.encounters, for: request)
    }

    // MARK: Immunizations
    public func getImmunizationGroups(_ request: BWell.HealthDataGroupRequest) async throws -> BWell.GroupResult<BWell.ImmunizationGroup> {
        .init(resources: SampleData.immunizations.map {
            BWell.ImmunizationGroup(id: $0.groupId, name: $0.name, coding: $0.coding, occurrenceDateTime: $0.date)
        })
    }
    public func getImmunizations(_ request: BWell.HealthDataRequest) async throws -> BWell.ResourceBundle<BWell.Immunization> {
        SampleData.bundle(SampleData.immunizations, for: request)
    }

    // MARK: Labs
    public func getLabGroups(_ request: BWell.HealthDataGroupRequest) async throws -> BWell.GroupResult<BWell.LabGroups> {
        .init(resources: SampleData.labs.map {
            BWell.LabGroups(id: $0.groupId, name: $0.name, coding: $0.coding, effectiveDateTime: $0.date)
        })
    }
    public func getLabs(_ request: BWell.HealthDataRequest) async throws -> BWell.ResourceBundle<BWell.Observation> {
        SampleData.bundle(SampleData.labs, for: request)
    }

    // MARK: Medications
    public func getMedicationGroups(_ request: BWell.HealthDataGroupRequest) async throws -> BWell.GroupResult<BWell.MedicationGroup> {
        .init(resources: SampleData.medications.map {
            BWell.MedicationGroup(id: $0.groupId, name: $0.name, coding: $0.coding, authoredOn: $0.date)
        })
    }
    public func getMedicationStatements(_ request: BWell.HealthDataRequest) async throws -> BWell.ResourceBundle<BWell.MedicationStatement> {
        SampleData.bundle(SampleData.medications, for: request)
    }

    // MARK: Procedures
    public func getProcedureGroups(_ request: BWell.HealthDataGroupRequest) async throws -> BWell.GroupResult<BWell.ProcedureGroups> {
        .init(resources: SampleData.procedures.map {
            BWell.ProcedureGroups(id: $0.groupId, name: $0.name, coding: $0.coding, performedDate: $0.date)
        })
    }
    public func getProcedures(_ request: BWell.HealthDataRequest) async throws -> BWell.ResourceBundle<BWell.Procedure> {
        SampleData.bundle(SampleData.procedures, for: request)
    }

    // MARK: Vital signs
    public func getVitalSignGroups(_ request: BWell.HealthDataGroupRequest) async throws -> BWell.GroupResult<BWell.VitalSignGroups> {
        .init(resources: SampleData.vitalSigns.map {
            BWell.VitalSignGroups(id: $0.groupId, name: $0.name, coding: $0.coding, effectiveDateTime: $0.date)
        })
    }
    public func getVitalSigns(_ request: BWell.HealthDataRequest) async throws -> BWell.ResourceBundle<BWell.Observation> {
        SampleData.bundle(SampleData.vitalSigns, for: request)
    }
}
