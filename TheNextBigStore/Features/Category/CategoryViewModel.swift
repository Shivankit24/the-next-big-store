//
//  CategoryViewModel.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Drives the Category page: loads the catalogue grouped by category and tracks the
/// selected category. Exactly one is always selected once data has loaded.
@Observable
final class CategoryViewModel {
    private(set) var state: LoadState<[CategorySection]> = .idle
    private(set) var selectedCategoryID: String?

    private let repository: any ProductRepository

    init(repository: any ProductRepository) {
        self.repository = repository
    }

    func isSelected(_ id: String) -> Bool {
        selectedCategoryID == id
    }

    /// Selects `id`, replacing the previous selection. Unknown ids are ignored, so a valid
    /// category is always selected.
    func select(_ id: String) {
        guard case .loaded(let sections) = state, sections.contains(where: { $0.id == id }) else { return }
        selectedCategoryID = id
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
            if !sections.contains(where: { $0.id == selectedCategoryID }) {
                selectedCategoryID = sections.first?.id
            }
            state = .loaded(sections)
        } catch {
            // A cancelled load (e.g. the view disappeared) is not a failure worth showing.
            state = Task.isCancelled ? .idle : .failed(error.localizedDescription)
        }
    }
}
