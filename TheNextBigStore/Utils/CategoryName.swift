//
//  CategoryName.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// Turns the backend's raw category (e.g. "men's clothing") into a display title.
nonisolated enum CategoryName {
    /// Capitalises the first letter of each word without touching the rest, so an
    /// apostrophe doesn't produce "Men'S" the way `String.capitalized` would.
    static func display(_ rawCategory: String) -> String {
        rawCategory
            .split(separator: " ")
            .map { String($0.prefix(1)).uppercased() + String($0.dropFirst()) }
            .joined(separator: " ")
    }
}
