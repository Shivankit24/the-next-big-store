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

    @Test func startsIdleWithNothingSelected() {
        let viewModel = CategoryViewModel(repository: StubProductRepository(result: .success([])))

        #expect(viewModel.state == .idle)
        #expect(viewModel.selectedCategoryID == nil)
    }

    @Test func loadGroupsByCategoryAndSelectsTheFirst() async {
        let viewModel = await makeLoadedViewModel()

        guard case .loaded(let sections) = viewModel.state else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(sections.map(\.id) == ["electronics", "jewelery", "men's clothing"])
        #expect(viewModel.selectedCategoryID == "electronics")
        #expect(viewModel.isSelected("electronics"))
    }

    @Test func selectingACategoryReplacesThePreviousSelection() async {
        let viewModel = await makeLoadedViewModel()

        viewModel.select("men's clothing")

        #expect(viewModel.isSelected("men's clothing"))
        #expect(!viewModel.isSelected("electronics"))
    }

    @Test func selectingTheSelectedCategoryKeepsItSelected() async {
        let viewModel = await makeLoadedViewModel()

        viewModel.select("electronics")

        #expect(viewModel.isSelected("electronics"))
    }

    @Test func selectingUnknownCategoryIsIgnored() async {
        let viewModel = await makeLoadedViewModel()

        viewModel.select("toys")

        #expect(viewModel.selectedCategoryID == "electronics")
    }

    @Test func reloadKeepsTheSelectedCategory() async {
        let viewModel = await makeLoadedViewModel()
        viewModel.select("jewelery")

        await viewModel.load()

        #expect(viewModel.selectedCategoryID == "jewelery")
    }

    @Test func loadFailureExposesErrorMessage() async {
        let viewModel = CategoryViewModel(repository: StubProductRepository(result: .failure(.badStatus(500))))

        await viewModel.load()

        #expect(viewModel.state == .failed(NetworkError.badStatus(500).localizedDescription))
        #expect(viewModel.selectedCategoryID == nil)
    }
}
