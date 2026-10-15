//
//  SessionRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 14-10-2026.
//

import Foundation
import Combine

@MainActor
protocol SessionRepository: AnyObject {
    var state: SessionState { get }
    var statePublisher: AnyPublisher<SessionState, Never> { get }

    func initialize(_ apiKey: String) async throws
    func validateSession() async
    func login(credentials: Credentials) async throws
    func logout()
}
