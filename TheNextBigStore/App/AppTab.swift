//
//  AppTab.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// The app's top-level tabs.
enum AppTab: Hashable, CaseIterable {
    case home
    case categories

    /// Whether the window-level global search bar shows while this tab is selected.
    ///
    /// This is the one place that decides it. To hide the bar on a page, return `false` for its
    /// tab, e.g. `case .profile: false`. The switch is exhaustive, so adding a tab forces
    /// a decision, and no other screen needs to change.
    var showsSearchBar: Bool {
        switch self {
        case .home, .categories: true
        }
    }
}
