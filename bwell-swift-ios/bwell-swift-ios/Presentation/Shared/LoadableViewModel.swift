//
//  LoadableViewModel.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 17-10-2026.
//

import Foundation

@MainActor
final class LoadableViewModel<Value>: ObservableObject {
    @Published private(set) var value: Value
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let loader: () async throws -> Value
    private var hasLoaded = false

    init(initialValue: Value, loader: @escaping () async throws -> Value) {
        self.value = initialValue
        self.loader = loader
    }

    // Loads once. Coming back to the screen doesn't fetch again.
    func load() async {
        guard !hasLoaded, !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            value = try await loader()
            hasLoaded = true
        } catch {
            Log.health.error("Failed to load health data: \(error.localizedDescription)")
            errorMessage = "We couldn't load this information. Please try again."
        }
    }
}
