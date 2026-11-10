//
//  CategoryView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Category page: one sticky row per category, exactly one expanded at a time.
struct CategoryView: View {
    @State private var viewModel: CategoryViewModel

    init(viewModel: CategoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(Constants.Category.title)
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
            categoryList(sections)
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

    private func categoryList(_ sections: [CategorySection]) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(sections) { section in
                        Section {
                            if viewModel.isExpanded(section.id) {
                                CategoryProductsView(section: section)
                                    .transition(.opacity)
                            }
                        } header: {
                            CategoryHeaderRow(
                                title: section.name,
                                productCount: section.productCount,
                                isExpanded: viewModel.isExpanded(section.id)
                            ) {
                                withAnimation(.snappy(duration: 0.3)) {
                                    viewModel.select(section.id)
                                }
                            }
                            .id(section.id)
                        }
                    }
                }
            }
            // Bring the newly opened category's row to the top once the layout has updated,
            // so the open category is always where the user is looking.
            .onChange(of: viewModel.expandedCategoryID) { _, newID in
                guard let newID else { return }
                withAnimation(.snappy(duration: 0.3)) {
                    proxy.scrollTo(newID, anchor: .top)
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
