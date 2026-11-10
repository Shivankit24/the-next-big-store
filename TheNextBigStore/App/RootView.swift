//
//  RootView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// The app's top-level view.
///
/// The global search bar lives here, once, above the tabs, instead of inside each page. Because
/// it sits outside the tab view it shrinks the space the pages live in rather than overlapping
/// their navigation bars, and it stays put as the user moves between tabs.
struct RootView: View {
    @State private var homeViewModel: HomeViewModel
    @State private var categoryViewModel: CategoryViewModel
    @State private var selectedTab: AppTab = .home
    @State private var isSearchPresented = false
    private let imageLoader: any ImageLoading
    private let makeSearchViewModel: () -> SearchViewModel
    private let enquiryViewModelFactory: EnquiryViewModelFactory

    init(container: AppContainer) {
        _homeViewModel = State(initialValue: container.makeHomeViewModel())
        _categoryViewModel = State(initialValue: container.makeCategoryViewModel())
        imageLoader = container.imageLoader
        makeSearchViewModel = container.makeSearchViewModel
        enquiryViewModelFactory = container.makeEnquiryViewModelFactory()
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedTab.showsSearchBar {
                SearchEntryBar { isSearchPresented = true }
                    .padding(.horizontal, Theme.Spacing.l)
                    .padding(.vertical, Theme.Spacing.s)
                    .background(.bar, ignoresSafeAreaEdges: .top)
                    .transition(.opacity)
            }

            TabView(selection: $selectedTab) {
                Tab(Constants.Tabs.home, systemImage: "house", value: AppTab.home) {
                    HomeView(viewModel: homeViewModel)
                }
                Tab(Constants.Tabs.categories, systemImage: "square.grid.2x2", value: AppTab.categories) {
                    CategoryView(viewModel: categoryViewModel)
                }
            }
        }
        .animation(.snappy(duration: 0.25), value: selectedTab.showsSearchBar)
        .environment(\.imageLoader, imageLoader)
        .environment(\.enquiryViewModelFactory, enquiryViewModelFactory)
        .fullScreenCover(isPresented: $isSearchPresented) {
            SearchView(viewModel: makeSearchViewModel())
        }
    }
}
