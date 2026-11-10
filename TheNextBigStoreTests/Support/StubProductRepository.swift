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

/// Serves a canned result, optionally after a delay, and counts requests.
struct StubProductRepository: ProductRepository {
    let result: Result<[Product], NetworkError>
    var delay: Duration = .zero
    let listCalls = CallCounter()
    let singleCalls = CallCounter()

    func fetchProducts() async throws -> [Product] {
        await listCalls.increment()
        try await Task.sleep(for: delay)
        return try result.get()
    }

    func fetchProduct(id: Int) async throws -> Product {
        await singleCalls.increment()
        guard let product = try result.get().first(where: { $0.id == id }) else {
            throw NetworkError.badStatus(404)
        }
        return product
    }
}
