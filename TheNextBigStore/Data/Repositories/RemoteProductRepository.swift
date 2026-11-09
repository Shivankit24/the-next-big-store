//
//  RemoteProductRepository.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// `ProductRepository` that reads products from the backend over HTTP.
nonisolated struct RemoteProductRepository: ProductRepository {
    private let client: any HTTPClient

    init(client: any HTTPClient) {
        self.client = client
    }

    func fetchProducts() async throws -> [Product] {
        try await client.send(.products)
    }

    func fetchProduct(id: Int) async throws -> Product {
        try await client.send(.product(id: id))
    }
}
