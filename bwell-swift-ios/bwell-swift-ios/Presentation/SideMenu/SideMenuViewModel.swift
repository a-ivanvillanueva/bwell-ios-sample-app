//
//  SideMenuViewModel.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 14-10-2026.
//

import Foundation

@MainActor
final class SideMenuViewModel: ObservableObject {
    private let session: SessionRepository
    private var router: NavigationRouter?

    @Published var optionSelected: SideMenuModel?

    init(session: SessionRepository) {
        self.session = session
    }

    func setup(router: NavigationRouter) {
        self.router = router
    }

    func navigate(to optionSelected: SideMenuModel) {
        guard let router = router else { return }

        // Handle logout separately
        if optionSelected == .logout {
            session.logout()
            return
        }

        // Update the selected option
        self.optionSelected = optionSelected

        // For other navigation, navigate and replace the current stack
        router.navigateAndReplace(to: optionSelected.destination)
    }
}
