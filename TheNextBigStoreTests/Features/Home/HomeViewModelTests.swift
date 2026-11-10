//
//  HomeViewModelTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Foundation
import Testing

@testable import TheNextBigStore

@MainActor
@Suite
struct HomeViewModelTests {
    private let products = (1...7).map { Product.fixture(id: $0, rate: Double($0)) }

    @Test func startsIdle() {
        let viewModel = HomeViewModel(repository: StubProductRepository(result: .success([])))

        #expect(viewModel.state == .idle)
    }

    @Test func loadPublishesFiveTopRatedProducts() async {
        let viewModel = HomeViewModel(repository: StubProductRepository(result: .success(products)))

        await viewModel.load()

        let expected = Array(products.filter { $0.id >= 3 }.reversed())
        #expect(viewModel.state == .loaded(expected))
    }

    @Test func loadFailureExposesErrorMessage() async {
        let viewModel = HomeViewModel(repository: StubProductRepository(result: .failure(.badStatus(500))))

        await viewModel.load()

        #expect(viewModel.state == .failed(NetworkError.badStatus(500).localizedDescription))
    }

    @Test func loadIfNeededDoesNotRefetchLoadedProducts() async {
        let repository = StubProductRepository(result: .success(products))
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(await repository.listCalls.value == 1)
    }

    @Test func loadIfNeededRetriesAfterFailure() async {
        let repository = StubProductRepository(result: .failure(.transport(.timedOut)))
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(await repository.listCalls.value == 2)
    }
}
