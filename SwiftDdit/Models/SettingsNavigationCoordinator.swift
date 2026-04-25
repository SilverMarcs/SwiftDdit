//
//  SettingsNavigationCoordinator.swift
//  SwiftDdit
//
//  Created by Codex on 25/03/2026.
//

import SwiftUI

@MainActor
@Observable
final class SettingsNavigationCoordinator {
    enum SheetDestination: Hashable, Identifiable {
        case settings

        var id: Self { self }
    }

    enum Route: Hashable {
        case accounts
        case appIcon
    }

    var presentedSheet: SheetDestination?
    var path = NavigationPath()

    func presentSettings(open route: Route? = nil) {
        if let route {
            path = NavigationPath()
            path.append(route)
        } else if presentedSheet == nil {
            path = NavigationPath()
        }

        presentedSheet = .settings
    }

    func dismissSettings() {
        presentedSheet = nil
        path = NavigationPath()
    }
}
