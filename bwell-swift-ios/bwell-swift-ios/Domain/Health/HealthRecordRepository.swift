//
//  HealthRecordRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 16-10-2026.
//

import Foundation

@MainActor
protocol HealthRecordRepository {
    func summary() async throws -> [HealthCategory: Int]
    func groups(in category: HealthCategory) async throws -> [HealthGroup]
    func records(in category: HealthCategory, group: HealthGroup) async throws -> [HealthRecord]
}
