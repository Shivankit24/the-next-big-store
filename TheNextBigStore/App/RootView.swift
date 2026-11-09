//
//  RootView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// The app's top-level view. Tabs for Search and Categories will be added here.
struct RootView: View {
    @State private var homeViewModel: HomeViewModel

    init(container: AppContainer) {
        _homeViewModel = State(initialValue: container.makeHomeViewModel())
    }

    var body: some View {
        HomeView(viewModel: homeViewModel)
    }
}
