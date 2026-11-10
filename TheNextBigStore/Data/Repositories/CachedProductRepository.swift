//
//  CachedProductRepository.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Keeps the product list in memory for the life of the app, so the Home and Category
/// tabs share one fetch and switching between them is instant. Concurrent requests share
/// a single download and failures are never cached, so retrying always asks again.
actor CachedProductRepository: ProductRepository {
    private let base: any ProductRepository
    private var cachedProducts: [Product]?
    private var inFlight: Task<[Product], Error>?

    init(wrapping base: any ProductRepository) {
        self.base = base
    }

    func fetchProducts() async throws -> [Product] {
        if let cachedProducts { return cachedProducts }
        if let inFlight { return try await inFlight.value }

        let download = Task { try await self.base.fetchProducts() }
        inFlight = download
        defer { inFlight = nil }

        let products = try await download.value
        cachedProducts = products
        return products
    }

    func fetchProduct(id: Int) async throws -> Product {
        if let cached = cachedProducts?.first(where: { $0.id == id }) { return cached }
        return try await base.fetchProduct(id: id)
    }
}
