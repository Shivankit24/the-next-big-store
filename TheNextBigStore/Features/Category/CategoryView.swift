//
//  CategoryView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Category page: a chip bar of every category pinned above the selected category's products.
struct CategoryView: View {
    @State private var viewModel: CategoryViewModel

    init(viewModel: CategoryViewModel) {
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
        case .loaded(let sections):
            categoryContent(sections)
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

    private func categoryContent(_ sections: [CategorySection]) -> some View {
        VStack(spacing: 0) {
            CategoryChipBar(
                items: sections.map { CategoryChipBar.Item(id: $0.id, title: $0.name) },
                selectedID: viewModel.selectedCategoryID
            ) { id in
                withAnimation(.snappy(duration: 0.25)) {
                    viewModel.select(id)
                }
            }

            // A ZStack, so during the cross-fade the outgoing and incoming categories overlap
            // instead of stacking and making the page jump.
            ZStack {
                if let section = sections.first(where: { viewModel.isSelected($0.id) }) {
                    ScrollView {
                        CategoryProductsView(section: section)
                    }
                    // A new identity per category gives each one a fresh scroll position at the top.
                    .id(section.id)
                    .transition(.opacity)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    CategoryView(viewModel: CategoryViewModel(repository: PreviewProductRepository()))
}
#endif
