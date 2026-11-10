//
//  Product+Fixture.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

@testable import TheNextBigStore

extension Product {
    static func fixture(
        id: Int = 1,
        title: String = "Item",
        price: Double = 10,
        category: String = "men's clothing",
        rate: Double = 4,
        count: Int = 100
    ) -> Product {
        Product(
            id: id,
            title: title,
            price: price,
            description: "Description",
            category: category,
            imageURL: URL(string: "https://example.com/\(id).png"),
            rating: Rating(rate: rate, count: count)
        )
    }
}
