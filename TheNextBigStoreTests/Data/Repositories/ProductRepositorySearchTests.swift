//
//  ProductRepositorySearchTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct ProductRepositorySearchTests {
    private let products = [
        Product.fixture(id: 1, title: "Slim Shirt"),
        Product.fixture(id: 2, title: "Gold Ring"),
    ]

    @Test func defaultSearchFiltersTheCatalogue() async throws {
        let repository = StubProductRepository(result: .success(products))

        let results = try await repository.searchProducts(matching: "ring")

        #expect(results.map(\.id) == [2])
    }

    @Test func cachedRepositorySearchesWithoutRefetching() async throws {
        let base = StubProductRepository(result: .success(products))
        let repository = CachedProductRepository(wrapping: base)

        _ = try await repository.searchProducts(matching: "shirt")
        let results = try await repository.searchProducts(matching: "ring")

        #expect(results.map(\.id) == [2])
        #expect(await base.listCalls.value == 1)
    }

    @Test func searchPropagatesErrors() async {
        let repository = StubProductRepository(result: .failure(.badStatus(500)))

        await #expect(throws: NetworkError.badStatus(500)) {
            _ = try await repository.searchProducts(matching: "shirt")
        }
    }
}
