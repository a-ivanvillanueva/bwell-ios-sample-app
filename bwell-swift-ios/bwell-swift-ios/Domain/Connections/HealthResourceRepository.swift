//
//  HealthResourceRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import Foundation

@MainActor
protocol HealthResourceRepository {
    func search(matching text: String?) async throws -> [HealthResource]
}
