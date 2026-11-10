//
//  ProductSearchTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct ProductSearchTests {
    private func product(
        _ id: Int, title: String, description: String = "Plain", category: String = "tops", rate: Double = 4
    ) -> Product {
        let base = Product.fixture(id: id, title: title, category: category, rate: rate)
        return Product(
            id: base.id, title: base.title, price: base.price, description: description,
            category: base.category, imageURL: base.imageURL, rating: base.rating
        )
    }

    @Test func matchesTitleIgnoringCase() {
        let products = [product(1, title: "Slim Fit Shirt"), product(2, title: "Gold Ring")]

        #expect(products.search("SHIRT").map(\.id) == [1])
    }

    @Test func matchesDescriptionAndCategoryName() {
        let products = [
            product(1, title: "A", description: "Soft cotton"),
            product(2, title: "B", category: "jewelery"),
            product(3, title: "C"),
        ]

        #expect(products.search("cotton").map(\.id) == [1])
        #expect(products.search("Jewelery").map(\.id) == [2])
    }

    @Test func ignoresDiacritics() {
        let products = [product(1, title: "Café Bag")]

        #expect(products.search("cafe").map(\.id) == [1])
    }

    @Test func everyWordMustMatchSomewhere() {
        let products = [
            product(1, title: "Slim Fit Shirt"),
            product(2, title: "Slim Jacket"),
            product(3, title: "Fit Band", description: "slim strap"),
        ]

        #expect(Set(products.search("slim fit").map(\.id)) == [1, 3])
    }

    @Test func titleMatchesComeBeforeOtherMatches() {
        let products = [
            product(1, title: "Backpack", description: "Fits a laptop", rate: 5),
            product(2, title: "Laptop Sleeve", rate: 3),
        ]

        #expect(products.search("laptop").map(\.id) == [2, 1])
    }

    @Test func matchesWithinEachGroupAreRankedByRating() {
        let products = [
            product(1, title: "Shirt A", rate: 3),
            product(2, title: "Shirt B", rate: 5),
        ]

        #expect(products.search("shirt").map(\.id) == [2, 1])
    }

    @Test func blankOrUnmatchedQueryReturnsNothing() {
        let products = [product(1, title: "Shirt")]

        #expect(products.search("").isEmpty)
        #expect(products.search("   ").isEmpty)
        #expect(products.search("zzz").isEmpty)
    }
}
