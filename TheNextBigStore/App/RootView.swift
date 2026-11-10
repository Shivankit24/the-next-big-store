//
//  RootView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// The app's top-level view: a tab bar with Home and Categories. Search opens from Home.
struct RootView: View {
    @State private var homeViewModel: HomeViewModel
    @State private var categoryViewModel: CategoryViewModel
    private let imageLoader: any ImageLoading
    private let makeSearchViewModel: () -> SearchViewModel

    init(container: AppContainer) {
        _homeViewModel = State(initialValue: container.makeHomeViewModel())
        _categoryViewModel = State(initialValue: container.makeCategoryViewModel())
        imageLoader = container.imageLoader
        makeSearchViewModel = container.makeSearchViewModel
    }

    var body: some View {
        TabView {
            Tab(Constants.Tabs.home, systemImage: "house") {
                HomeView(viewModel: homeViewModel, makeSearchViewModel: makeSearchViewModel)
            }
            Tab(Constants.Tabs.categories, systemImage: "square.grid.2x2") {
                CategoryView(viewModel: categoryViewModel)
            }
        }
        .environment(\.imageLoader, imageLoader)
    }
}
