//
//  ProductTopRatedTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct ProductTopRatedTests {
    @Test func ordersByRateDescending() {
        let products = [
            Product.fixture(id: 1, rate: 3.9),
            Product.fixture(id: 2, rate: 4.8),
            Product.fixture(id: 3, rate: 4.1),
        ]

        #expect(products.topRated(limit: 3).map(\.id) == [2, 3, 1])
    }

    @Test func sameRateIsOrderedByCountDescending() {
        let products = [
            Product.fixture(id: 1, rate: 4.5, count: 10),
            Product.fixture(id: 2, rate: 4.5, count: 300),
        ]

        #expect(products.topRated(limit: 2).map(\.id) == [2, 1])
    }

    @Test func sameRateAndCountIsOrderedByTitleAlphabetically() {
        let products = [
            Product.fixture(id: 1, title: "Zebra Tee", rate: 4.5, count: 10),
            Product.fixture(id: 2, title: " apple Tee", rate: 4.5, count: 10),
            Product.fixture(id: 3, title: "Mango Tee", rate: 4.5, count: 10),
        ]

        #expect(products.topRated(limit: 3).map(\.id) == [2, 3, 1])
    }

    @Test func identicalProductsFallBackToId() {
        let products = [
            Product.fixture(id: 9, title: "Same", rate: 4, count: 1),
            Product.fixture(id: 3, title: "Same", rate: 4, count: 1),
        ]

        #expect(products.topRated(limit: 2).map(\.id) == [3, 9])
    }

    @Test func respectsLimit() {
        let products = (1...8).map { Product.fixture(id: $0, rate: Double($0) / 2) }

        #expect(products.topRated(limit: 5).map(\.id) == [8, 7, 6, 5, 4])
        #expect(products.topRated(limit: 0).isEmpty)
        #expect(products.topRated(limit: 20).count == 8)
    }
}
