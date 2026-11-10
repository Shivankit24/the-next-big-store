//
//  Product.swift
//  TheNextBigStore
//
//  Created by Shivankit on 09/11/26.
//

import Foundation

/// A catalogue product, as the app understands it.
///
/// Deliberately independent of any API's JSON shape (see `ProductDTO` for that), and free of
/// UI and networking concerns, so the data source can change without touching it.
nonisolated struct Product: Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: ProductCategory
    let imageURL: URL?
    let rating: Rating
}
