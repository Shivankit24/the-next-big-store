//
//  SearchViewModelTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Foundation
import Testing

@testable import TheNextBigStore

@MainActor
@Suite
struct SearchViewModelTests {
    private let products = [
        Product.fixture(id: 1, title: "Slim Shirt", rate: 3),
        Product.fixture(id: 2, title: "Shirt Pro", rate: 5),
        Product.fixture(id: 3, title: "Gold Ring"),
    ]

    private func makeViewModel(
        result: Result<[Product], NetworkError>? = nil, delay: Duration = .zero
    ) -> (SearchViewModel, StubProductRepository) {
        let repository = StubProductRepository(result: result ?? .success(products), delay: delay)
        return (SearchViewModel(repository: repository), repository)
    }

    @Test func startsBlank() {
        let (viewModel, _) = makeViewModel()

        #expect(viewModel.state == .idle)
        #expect(viewModel.query.isEmpty)
        #expect(!viewModel.canSearch)
    }

    @Test func typingAloneDoesNotSearch() async {
        let (viewModel, repository) = makeViewModel()

        viewModel.query = "shirt"

        #expect(viewModel.state == .idle)
        #expect(await repository.listCalls.value == 0)
        #expect(viewModel.canSearch)
    }

    @Test func whitespaceOnlyQueryCannotSearch() async {
        let (viewModel, repository) = makeViewModel()
        viewModel.query = "   "

        await viewModel.search()

        #expect(!viewModel.canSearch)
        #expect(viewModel.state == .idle)
        #expect(await repository.listCalls.value == 0)
    }

    @Test func searchPublishesRankedResultsForTheTrimmedQuery() async {
        let (viewModel, _) = makeViewModel()
        viewModel.query = "  shirt "

        await viewModel.search()

        #expect(viewModel.state == .results(query: "shirt", [products[1], products[0]]))
    }

    @Test func noMatchesIsAnEmptyResult() async {
        let (viewModel, _) = makeViewModel()
        viewModel.query = "zzz"

        await viewModel.search()

        #expect(viewModel.state == .results(query: "zzz", []))
    }

    @Test func failureExposesErrorMessage() async {
        let (viewModel, _) = makeViewModel(result: .failure(.badStatus(500)))
        viewModel.query = "shirt"

        await viewModel.search()

        #expect(viewModel.state == .failed(NetworkError.badStatus(500).localizedDescription))
    }

    @Test func clearEmptiesTheQueryAndReturnsToBlank() async {
        let (viewModel, _) = makeViewModel()
        viewModel.query = "shirt"
        await viewModel.search()

        viewModel.clear()

        #expect(viewModel.query.isEmpty)
        #expect(viewModel.state == .idle)
    }

    @Test func clearingWhileSearchingDiscardsTheLateResponse() async throws {
        let (viewModel, _) = makeViewModel(delay: .milliseconds(100))
        viewModel.query = "shirt"

        let search = Task { await viewModel.search() }
        try await Task.sleep(for: .milliseconds(20))
        viewModel.clear()
        await search.value

        #expect(viewModel.state == .idle)
    }
}
