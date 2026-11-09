//
//  HomeViewModel.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Drives the Home page: loads the catalogue and exposes the top rated products.
@Observable
final class HomeViewModel {
    private(set) var state: LoadState<[Product]> = .idle

    private let repository: any ProductRepository

    init(repository: any ProductRepository) {
        self.repository = repository
    }

    /// Loads products unless they are already on screen, e.g. when returning to the page.
    func loadIfNeeded() async {
        if case .loaded = state { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let products = try await repository.fetchProducts()
            state = .loaded(products.topRated(limit: Constants.Catalogue.featuredCount))
        } catch {
            // A cancelled load (e.g. the view disappeared) is not a failure worth showing.
            state = Task.isCancelled ? .idle : .failed(error.localizedDescription)
        }
    }
}
