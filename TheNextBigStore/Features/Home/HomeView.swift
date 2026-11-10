//
//  HomeView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Home page: the top rated products as a grid of tiles.
struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .toolbarVisibility(.hidden, for: .navigationBar)
                .task { await viewModel.loadIfNeeded() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let products):
            ScrollView {
                // The title is ordinary content, so it scrolls away with the page. The global
                // search bar is the only element that stays pinned.
                VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                    Text(Constants.Home.title)
                        .font(.title2.bold())
                        .accessibilityAddTraits(.isHeader)
                    ProductGridView(products: products)
                }
                .padding(Theme.Spacing.l)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        case .failed(let message):
            ContentUnavailableView {
                Label(Constants.Home.errorTitle, systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button(Constants.Home.retry) {
                    Task { await viewModel.load() }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    HomeView(viewModel: HomeViewModel(repository: PreviewProductRepository()))
}
#endif
