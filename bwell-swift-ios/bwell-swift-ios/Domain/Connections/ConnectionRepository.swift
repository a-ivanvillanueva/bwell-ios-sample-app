//
//  ConnectionRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 15-10-2026.
//

import Foundation

@MainActor
protocol ConnectionRepository {
    func connections() async throws -> [Connection]
    func delete(_ connectionId: String) async throws
    func disconnect(_ connectionId: String) async throws
    func oauthURL(for connectionId: String) async throws -> URL
}
