//
//  CategoryNameTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct CategoryNameTests {
    @Test func capitalisesEachWord() {
        #expect(CategoryName.display("men's clothing") == "Men's Clothing")
        #expect(CategoryName.display("jewelery") == "Jewelery")
    }

    @Test func collapsesExtraSpaces() {
        #expect(CategoryName.display("  women's   clothing ") == "Women's Clothing")
    }

    @Test func emptyStaysEmpty() {
        #expect(CategoryName.display("").isEmpty)
    }
}
