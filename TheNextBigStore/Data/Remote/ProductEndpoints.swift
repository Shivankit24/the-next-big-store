//
//  ProductEndpoints.swift
//  TheNextBigStore
//
//  Created by Shivankit on 09/11/26.
//

import Foundation

/// Backend routes for products (see `api_contract_data_models.md`).
/// The local Node server mirrors the Fake Store API paths.
extension Endpoint {
    /// `GET /products`
    nonisolated static var products: Endpoint {
        Endpoint(path: "/products")
    }

    /// `GET /products/{id}`
    nonisolated static func product(id: Int) -> Endpoint {
        Endpoint(path: "/products/\(id)")
    }
}
