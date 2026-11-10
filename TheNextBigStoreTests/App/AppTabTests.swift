//
//  AppTabTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct AppTabTests {
    @Test func browsingTabsShowTheGlobalSearchBar() {
        #expect(AppTab.home.showsSearchBar)
        #expect(AppTab.categories.showsSearchBar)
    }
}
