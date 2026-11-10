//
//  CategorySection.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// One category on the Category page: its best rated products first, then the rest.
nonisolated struct CategorySection: Identifiable, Equatable, Sendable {
    /// The backend's raw category string.
    let id: String
    let topRated: [Product]
    let additional: [Product]

    var name: String { CategoryName.display(id) }
    var productCount: Int { topRated.count + additional.count }
}

extension Sequence where Element == Product {
    /// Groups products by category. Categories are ordered alphabetically so the order
    /// doesn't depend on how the data source happens to return products; inside a category,
    /// products are ranked best first, with the first `topRatedLimit` as "top rated".
    nonisolated func groupedByCategory(topRatedLimit: Int) -> [CategorySection] {
        let groups = Dictionary(grouping: self, by: \.category)
        return groups.keys
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            .map { category in
                let products = groups[category] ?? []
                let ranked = products.topRated(limit: products.count)
                return CategorySection(
                    id: category,
                    topRated: Array(ranked.prefix(Swift.max(0, topRatedLimit))),
                    additional: Array(ranked.dropFirst(Swift.max(0, topRatedLimit)))
                )
            }
    }
}
