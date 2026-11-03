//
//  NavigationRouterTests.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 02-11-2026.
//

import Testing
@testable import bwell_swift_ios

@MainActor
struct NavigationRouterTests {
    @Test func navigatingAppendsRoutes() {
        let router = NavigationRouter()
        router.navigate(to: .home)
        router.navigate(to: .profile)
        #expect(router.path == [.home, .profile])
    }

    @Test func replacingDropsTheOldStack() {
        let router = NavigationRouter()
        router.navigate(to: .home)
        router.navigate(to: .profile)

        router.navigateAndReplace(to: .manageConnections)

        #expect(router.path == [.manageConnections])
    }

    @Test func goingBackOnAnEmptyStackDoesNothing() {
        let router = NavigationRouter()
        router.goBack()
        #expect(router.path.isEmpty)
    }

    @Test func navigatingToTheRootEmptiesTheStack() {
        let router = NavigationRouter()
        router.navigate(to: .home)
        router.navigateToRoot()
        #expect(router.path.isEmpty)
    }

    @Test func routesCarryDomainValuesNotSdkTypes() {
        let router = NavigationRouter()
        router.navigate(to: .healthGroups(.labs))
        #expect(router.path == [.healthGroups(.labs)])
    }
}
