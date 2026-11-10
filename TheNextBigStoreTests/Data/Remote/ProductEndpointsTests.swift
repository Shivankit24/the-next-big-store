//
//  ProductEndpointsTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 09/11/26.
//

import Foundation
import Testing

@testable import TheNextBigStore

@Suite
struct ProductEndpointsTests {
    @Test func productsListPath() {
        #expect(Endpoint.products.path == "/products")
        #expect(Endpoint.products.method == .get)
    }

    @Test func singleProductPathIncludesId() {
        #expect(Endpoint.product(id: 4).path == "/products/4")
    }
}
