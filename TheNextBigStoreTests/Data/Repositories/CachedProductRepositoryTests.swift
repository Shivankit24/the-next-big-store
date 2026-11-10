//
//  CachedProductRepositoryTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct CachedProductRepositoryTests {
    private let products = [Product.fixture(id: 1), Product.fixture(id: 2)]

    @Test func secondFetchIsServedFromCache() async throws {
        let base = StubProductRepository(result: .success(products))
        let repository = CachedProductRepository(wrapping: base)

        let first = try await repository.fetchProducts()
        let second = try await repository.fetchProducts()

        #expect(first == products)
        #expect(second == products)
        #expect(await base.listCalls.value == 1)
    }

    @Test func concurrentFetchesShareOneRequest() async throws {
        let base = StubProductRepository(result: .success(products), delay: .milliseconds(50))
        let repository = CachedProductRepository(wrapping: base)

        async let first = repository.fetchProducts()
        async let second = repository.fetchProducts()
        _ = try await (first, second)

        #expect(await base.listCalls.value == 1)
    }

    @Test func failuresAreNotCached() async {
        let base = StubProductRepository(result: .failure(.badStatus(500)))
        let repository = CachedProductRepository(wrapping: base)

        _ = try? await repository.fetchProducts()
        _ = try? await repository.fetchProducts()

        #expect(await base.listCalls.value == 2)
    }

    @Test func singleProductComesFromCachedListWhenAvailable() async throws {
        let base = StubProductRepository(result: .success(products))
        let repository = CachedProductRepository(wrapping: base)

        _ = try await repository.fetchProducts()
        let product = try await repository.fetchProduct(id: 2)

        #expect(product.id == 2)
        #expect(await base.singleCalls.value == 0)
    }

    @Test func singleProductFallsBackToBaseWhenNotCached() async throws {
        let base = StubProductRepository(result: .success(products))
        let repository = CachedProductRepository(wrapping: base)

        let product = try await repository.fetchProduct(id: 1)

        #expect(product.id == 1)
        #expect(await base.singleCalls.value == 1)
    }
}
