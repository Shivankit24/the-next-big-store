//
//  RemoteProductRepositoryTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Foundation
import Testing

@testable import TheNextBigStore

@Suite
struct RemoteProductRepositoryTests {
    @Test func fetchProductsRequestsListAndMapsToDomain() async throws {
        let client = StubHTTPClient { endpoint in
            guard endpoint.path == "/products" else { throw NetworkError.badStatus(404) }
            return [ProductDTO.fixture(id: 1), ProductDTO.fixture(id: 2, title: "Second ")]
        }

        let products = try await RemoteProductRepository(client: client).fetchProducts()

        #expect(products.map(\.id) == [1, 2])
        #expect(products[1].title == "Second")
    }

    @Test func fetchProductRequestsProductByIdAndMapsToDomain() async throws {
        let client = StubHTTPClient { endpoint in
            guard endpoint.path == "/products/7" else { throw NetworkError.badStatus(404) }
            return ProductDTO.fixture(id: 7)
        }

        let product = try await RemoteProductRepository(client: client).fetchProduct(id: 7)

        #expect(product.id == 7)
    }

    @Test func propagatesClientErrors() async {
        let client = StubHTTPClient { _ in throw NetworkError.badStatus(500) }

        await #expect(throws: NetworkError.badStatus(500)) {
            _ = try await RemoteProductRepository(client: client).fetchProducts()
        }
    }
}
