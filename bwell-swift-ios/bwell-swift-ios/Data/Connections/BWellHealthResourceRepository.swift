//
//  BWellHealthResourceRepository.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 16-10-2026.
//

import Foundation
import BWellSDK

@MainActor
final class BWellHealthResourceRepository: HealthResourceRepository {
    private let sdkManager: BWellSDKManager

    // Demo location (Baltimore). A real app would get this from a location service.
    private let searchLocation = BWell.SearchHealthResourcesRequest.Location(latitude: 39.2848102, longitude: -76.702898)

    init(sdkManager: BWellSDKManager) {
        self.sdkManager = sdkManager
    }

    func search(matching text: String?) async throws -> [HealthResource] {
        let request = BWell.SearchHealthResourcesRequest(
            page: 0,
            pageSize: 100,
            search: text,
            filters: BWell.SearchHealthResourcesRequest.Filter(includePopulatedProaOnly: true),
            orderBy: [BWell.SearchHealthResourcesRequest.OrderBy(field: .distance, order: .asc)],
            location: searchLocation
        )

        let response = try await sdkManager.search().searchHealthResources(request)

        return (response.results ?? []).compactMap(HealthResource.init(sdk:))
    }
}
