//
//  CategorySection.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// One category on the Category page: its best rated products first, then the rest.
nonisolated struct CategorySection: Identifiable, Equatable, Sendable {
    let category: ProductCategory
    let topRated: [Product]
    let additional: [Product]

    var id: String { category.id }
    var name: String { category.name }
    var productCount: Int { topRated.count + additional.count }
}

extension Sequence where Element == Product {
    /// Groups products by category. Categories are ordered alphabetically by name so the order
    /// doesn't depend on how the data source happens to return products; inside a category,
    /// products are ranked best first, with the first `topRatedLimit` as "top rated".
    nonisolated func groupedByCategory(topRatedLimit: Int) -> [CategorySection] {
        let limit = Swift.max(0, topRatedLimit)
        return Dictionary(grouping: self, by: \.category)
            .sorted { $0.key.name.localizedCaseInsensitiveCompare($1.key.name) == .orderedAscending }
            .map { category, products in
                let ranked = products.topRated(limit: products.count)
                return CategorySection(
                    category: category,
                    topRated: Array(ranked.prefix(limit)),
                    additional: Array(ranked.dropFirst(limit))
                )
            }
    }
}
