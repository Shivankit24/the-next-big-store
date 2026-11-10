//
//  CategorySectionTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct CategorySectionTests {
    @Test func groupsByCategoryInAlphabeticalOrder() {
        let products = [
            Product.fixture(id: 1, category: "men's clothing"),
            Product.fixture(id: 2, category: "electronics"),
            Product.fixture(id: 3, category: "jewelery"),
            Product.fixture(id: 4, category: "electronics"),
        ]

        let sections = products.groupedByCategory(topRatedLimit: 5)

        #expect(sections.map(\.id) == ["electronics", "jewelery", "men's clothing"])
        #expect(sections[0].productCount == 2)
    }

    @Test func splitsTopRatedFromAdditionalAndRanksBoth() {
        let products = (1...8).map { Product.fixture(id: $0, category: "tops", rate: Double($0) / 2) }

        let section = products.groupedByCategory(topRatedLimit: 5)[0]

        #expect(section.topRated.map(\.id) == [8, 7, 6, 5, 4])
        #expect(section.additional.map(\.id) == [3, 2, 1])
    }

    @Test func smallCategoryHasNoAdditionalProducts() {
        let products = [Product.fixture(id: 1, category: "tops"), Product.fixture(id: 2, category: "tops")]

        let section = products.groupedByCategory(topRatedLimit: 5)[0]

        #expect(section.topRated.count == 2)
        #expect(section.additional.isEmpty)
    }

    @Test func exposesDisplayName() {
        let section = [Product.fixture(category: "women's clothing")].groupedByCategory(topRatedLimit: 5)[0]

        #expect(section.name == "Women's Clothing")
    }

    @Test func noProductsMeansNoSections() {
        #expect([Product]().groupedByCategory(topRatedLimit: 5).isEmpty)
    }
}
