//
//  PriceFormatterTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct PriceFormatterTests {
    @Test func formatsAustralianDollars() {
        #expect(PriceFormatter.string(from: 109.95) == "$109.95")
    }

    @Test func alwaysShowsTwoDecimalPlaces() {
        #expect(PriceFormatter.string(from: 22.3) == "$22.30")
    }

    @Test func groupsThousands() {
        #expect(PriceFormatter.string(from: 1234.5) == "$1,234.50")
    }
}
