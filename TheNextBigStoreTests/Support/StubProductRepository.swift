//
//  StubProductRepository.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

@testable import TheNextBigStore

actor CallCounter {
    private(set) var value = 0

    func increment() { value += 1 }
}

/// Serves a canned result and counts how many times the list was requested.
struct StubProductRepository: ProductRepository {
    let result: Result<[Product], NetworkError>
    let listCalls = CallCounter()

    func fetchProducts() async throws -> [Product] {
        await listCalls.increment()
        return try result.get()
    }

    func fetchProduct(id: Int) async throws -> Product {
        guard let product = try result.get().first(where: { $0.id == id }) else {
            throw NetworkError.badStatus(404)
        }
        return product
    }
}
