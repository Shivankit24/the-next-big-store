//
//  ProductDTO.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Wire format of a product as the Fake Store API (and the local Node server mirroring it)
/// returns it. Lives in the Data layer on purpose: when the real API arrives with different
/// models, only this type and its mapping change; the domain and every screen stay untouched.
nonisolated struct ProductDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: RatingDTO

    struct RatingDTO: Decodable, Sendable {
        let rate: Double
        let count: Int
    }

    /// Maps the wire format to the app's own `Product`. The Fake Store API only provides a
    /// lower-case category string, so the display name is derived here; a real API would
    /// supply its own.
    func asProduct() -> Product {
        Product(
            id: id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            price: price,
            description: description,
            category: ProductCategory(id: category, name: CategoryName.display(category)),
            imageURL: URL(string: image),
            rating: Rating(rate: rating.rate, count: rating.count)
        )
    }
}
