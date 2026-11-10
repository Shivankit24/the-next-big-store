//
//  SearchView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Global search page. Opens blank with the keyboard up; results appear only after the
/// search button is tapped. Cancel, outside the bar, leaves the search flow.
struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        // Search is presented full screen, outside the tabs, so it needs its own stack to open products.
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: Theme.Spacing.m) {
                    SearchBarView(
                        text: $viewModel.query,
                        canSearch: viewModel.canSearch,
                        onSearch: { Task { await viewModel.search() } },
                        onClear: viewModel.clear
                    )
                    Button(Constants.Search.cancel) { dismiss() }
                }
                .padding(.horizontal, Theme.Spacing.l)
                .padding(.vertical, Theme.Spacing.s)

                Divider()
                content
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
            .productDetailsDestination()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .results(let query, let products):
            if products.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                resultsList(query: query, products: products)
            }
        case .failed(let message):
            ContentUnavailableView {
                Label(Constants.Home.errorTitle, systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button(Constants.Home.retry) {
                    Task { await viewModel.search() }
                }
            }
        }
    }

    private func resultsList(query: String, products: [Product]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                Text(Constants.Search.resultsTitle(count: products.count, query: query))
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                ProductGridView(products: products)
            }
            .padding(Theme.Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#if DEBUG
#Preview {
    SearchView(viewModel: SearchViewModel(repository: PreviewProductRepository()))
}
#endif
