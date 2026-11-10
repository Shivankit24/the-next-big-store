//
//  ProductRepository.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Source of catalogue products. Features depend on this protocol only, so the
/// underlying data source (Fake Store via the Node server today) can be replaced.
nonisolated protocol ProductRepository: Sendable {
    func fetchProducts() async throws -> [Product]
    func fetchProduct(id: Int) async throws -> Product

    /// Products matching `query`. Implementations backed by an API with its own search can
    /// override this; the default searches the full catalogue on the device.
    func searchProducts(matching query: String) async throws -> [Product]
}

extension ProductRepository {
    nonisolated func searchProducts(matching query: String) async throws -> [Product] {
        try await fetchProducts().search(query)
    }
}
