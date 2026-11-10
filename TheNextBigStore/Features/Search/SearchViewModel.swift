//
//  SearchViewModel.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation
import Observation

/// What the Search page is showing.
enum SearchState: Equatable {
    /// Nothing searched yet: a blank page.
    case idle
    case loading
    /// The outcome of the last search. An empty list means no matches.
    case results(query: String, [Product])
    case failed(String)
}

/// Drives the Search page. Typing only edits `query`; nothing is searched until `search()`.
@Observable
final class SearchViewModel {
    var query = ""
    private(set) var state: SearchState = .idle

    private let repository: any ProductRepository
    /// Incremented by every search and clear, so a slow, outdated response can't overwrite a newer state.
    private var generation = 0

    init(repository: any ProductRepository) {
        self.repository = repository
    }

    var canSearch: Bool {
        !trimmedQuery.isEmpty
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func search() async {
        let term = trimmedQuery
        guard !term.isEmpty else { return }

        generation += 1
        let current = generation
        state = .loading
        do {
            let products = try await repository.searchProducts(matching: term)
            guard current == generation else { return }
            state = .results(query: term, products)
        } catch {
            guard current == generation, !Task.isCancelled else { return }
            state = .failed(error.localizedDescription)
        }
    }

    /// Empties the search term and returns to the blank page.
    func clear() {
        generation += 1
        query = ""
        state = .idle
    }
}
