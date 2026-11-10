//
//  PlaceholderEnquiryRepositoryTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Testing

@testable import TheNextBigStore

@Suite
struct PlaceholderEnquiryRepositoryTests {
    @Test func acceptsEveryEnquiryWithoutFailing() async throws {
        let enquiry = Enquiry(
            productID: 1, productTitle: "Item", name: "Jane", contact: .email("jane@example.com"), message: "Hi"
        )

        try await PlaceholderEnquiryRepository().submit(enquiry)
    }
}
