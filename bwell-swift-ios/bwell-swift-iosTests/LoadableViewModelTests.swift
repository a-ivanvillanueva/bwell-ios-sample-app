//
//  LadableViewModelTests.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 27-10-2026.
//

import Foundation
import Testing
@testable import bwell_swift_ios

@MainActor
struct LoadableViewModelTests {
    @Test func loadsTheValueAndStopsLoading() async {
        let viewModel = LoadableViewModel(initialValue: [Int]()) { [1, 2, 3] }

        await viewModel.load()

        #expect(viewModel.value == [1, 2, 3])
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func aFailureKeepsTheInitialValueAndSetsAMessage() async {
        let viewModel = LoadableViewModel(initialValue: [Int]()) { throw TestError() }

        await viewModel.load()

        #expect(viewModel.value.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(!viewModel.isLoading)
    }

    @Test func doesNotLoadAgainAfterSuccess() async {
        var calls = 0
        let viewModel = LoadableViewModel(initialValue: 0) {
            calls += 1
            return calls
        }

        await viewModel.load()
        await viewModel.load()

        #expect(calls == 1)
        #expect(viewModel.value == 1)
    }

    @Test func triesAgainAfterAFailure() async {
        var calls = 0
        let viewModel = LoadableViewModel(initialValue: 0) {
            calls += 1
            if calls == 1 { throw TestError() }
            return calls
        }

        await viewModel.load()
        #expect(viewModel.errorMessage != nil)

        await viewModel.load()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.value == 2)
    }
}
