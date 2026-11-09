//
//  Product+TopRated.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

extension Sequence where Element == Product {
    /// The highest-rated products, best first.
    ///
    /// Ordered by `rating.rate`, then `rating.count`, then title alphabetically
    /// (case-insensitive, ignoring surrounding whitespace). `id` is a final tie-break
    /// so the result is always deterministic.
    nonisolated func topRated(limit: Int) -> [Product] {
        let ranked = sorted { lhs, rhs in
            if lhs.rating.rate != rhs.rating.rate { return lhs.rating.rate > rhs.rating.rate }
            if lhs.rating.count != rhs.rating.count { return lhs.rating.count > rhs.rating.count }
            let titleOrder = lhs.title.trimmingCharacters(in: .whitespaces)
                .localizedCaseInsensitiveCompare(rhs.title.trimmingCharacters(in: .whitespaces))
            if titleOrder != .orderedSame { return titleOrder == .orderedAscending }
            return lhs.id < rhs.id
        }
        return Array(ranked.prefix(max(0, limit)))
    }
}
