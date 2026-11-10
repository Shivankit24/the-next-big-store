//
//  CategoryViewModelTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@MainActor
@Suite
struct CategoryViewModelTests {
    private let products = [
        Product.fixture(id: 1, category: "men's clothing"),
        Product.fixture(id: 2, category: "electronics"),
        Product.fixture(id: 3, category: "jewelery"),
    ]

    private func makeLoadedViewModel() async -> CategoryViewModel {
        let viewModel = CategoryViewModel(repository: StubProductRepository(result: .success(products)))
        await viewModel.load()
        return viewModel
    }

    @Test func startsIdleWithNothingExpanded() {
        let viewModel = CategoryViewModel(repository: StubProductRepository(result: .success([])))

        #expect(viewModel.state == .idle)
        #expect(viewModel.expandedCategoryID == nil)
    }

    @Test func loadGroupsByCategoryAndExpandsTheFirst() async {
        let viewModel = await makeLoadedViewModel()

        guard case .loaded(let sections) = viewModel.state else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(sections.map(\.id) == ["electronics", "jewelery", "men's clothing"])
        #expect(viewModel.expandedCategoryID == "electronics")
        #expect(viewModel.isExpanded("electronics"))
    }

    @Test func selectingACategoryCollapsesThePreviousOne() async {
        let viewModel = await makeLoadedViewModel()

        viewModel.select("men's clothing")

        #expect(viewModel.isExpanded("men's clothing"))
        #expect(!viewModel.isExpanded("electronics"))
    }

    @Test func selectingTheExpandedCategoryKeepsItExpanded() async {
        let viewModel = await makeLoadedViewModel()

        viewModel.select("electronics")

        #expect(viewModel.isExpanded("electronics"))
    }

    @Test func selectingUnknownCategoryIsIgnored() async {
        let viewModel = await makeLoadedViewModel()

        viewModel.select("toys")

        #expect(viewModel.expandedCategoryID == "electronics")
    }

    @Test func reloadKeepsTheSelectedCategory() async {
        let viewModel = await makeLoadedViewModel()
        viewModel.select("jewelery")

        await viewModel.load()

        #expect(viewModel.expandedCategoryID == "jewelery")
    }

    @Test func loadFailureExposesErrorMessage() async {
        let viewModel = CategoryViewModel(repository: StubProductRepository(result: .failure(.badStatus(500))))

        await viewModel.load()

        #expect(viewModel.state == .failed(NetworkError.badStatus(500).localizedDescription))
        #expect(viewModel.expandedCategoryID == nil)
    }
}
