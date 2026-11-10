//
//  Product+Search.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

extension Sequence where Element == Product {
    /// Products whose title, description or category name match every word of `query`.
    ///
    /// Matching ignores case and diacritics ("cafe" finds "Café"). Products whose *title*
    /// matches every word come first, then the rest, each group ranked best rated first.
    /// A blank query matches nothing.
    nonisolated func search(_ query: String) -> [Product] {
        let terms = query.split(whereSeparator: \.isWhitespace).map(String.init)
        guard !terms.isEmpty else { return [] }

        let matching = filter { product in
            terms.allSatisfy { term in
                product.title.localizedStandardContains(term)
                    || product.description.localizedStandardContains(term)
                    || product.category.name.localizedStandardContains(term)
            }
        }
        let titleMatches = matching.filter { product in
            terms.allSatisfy { product.title.localizedStandardContains($0) }
        }
        let titleMatchIDs = Set(titleMatches.map(\.id))
        let otherMatches = matching.filter { !titleMatchIDs.contains($0.id) }

        return titleMatches.topRated(limit: titleMatches.count) + otherMatches.topRated(limit: otherMatches.count)
    }
}
