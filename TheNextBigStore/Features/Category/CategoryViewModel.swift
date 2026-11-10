//
//  CategoryViewModel.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Observation

/// Drives the Category page: loads the catalogue grouped by category and tracks which
/// single category is expanded. Exactly one is always expanded once data has loaded.
@Observable
final class CategoryViewModel {
    private(set) var state: LoadState<[CategorySection]> = .idle
    private(set) var expandedCategoryID: String?

    private let repository: any ProductRepository

    init(repository: any ProductRepository) {
        self.repository = repository
    }

    func isExpanded(_ id: String) -> Bool {
        expandedCategoryID == id
    }

    /// Expands `id`, which collapses whichever category was open. Selecting the category
    /// that is already open does nothing, so a category is always expanded.
    func select(_ id: String) {
        guard case .loaded(let sections) = state, sections.contains(where: { $0.id == id }) else { return }
        expandedCategoryID = id
    }

    func loadIfNeeded() async {
        if case .loaded = state { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let products = try await repository.fetchProducts()
            let sections = products.groupedByCategory(topRatedLimit: Constants.Catalogue.topRatedPerCategory)
            if !sections.contains(where: { $0.id == expandedCategoryID }) {
                expandedCategoryID = sections.first?.id
            }
            state = .loaded(sections)
        } catch {
            // A cancelled load (e.g. the view disappeared) is not a failure worth showing.
            state = Task.isCancelled ? .idle : .failed(error.localizedDescription)
        }
    }
}
