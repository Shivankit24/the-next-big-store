//
//  ProductCategory.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

/// A product category as the app understands it: a stable identity plus the name to show.
/// The data source decides both, so a real API can supply proper names or ids of its own.
nonisolated struct ProductCategory: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
}
