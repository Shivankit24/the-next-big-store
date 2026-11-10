//
//  RemoteEnquiryRepositoryTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Foundation
import Testing

@testable import TheNextBigStore

@Suite
struct RemoteEnquiryRepositoryTests {
    private func enquiry(contact: ContactDetail) -> Enquiry {
        Enquiry(productID: 9, productTitle: "Slim Shirt", name: "Jane Doe", contact: contact, message: "Hello")
    }

    private func jsonObject(_ body: Data?) throws -> [String: Any] {
        let data = try #require(body)
        return try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    @Test func postsJSONToTheEnquiriesEndpoint() async throws {
        let client = StubHTTPClient { endpoint in
            guard endpoint.path == "/enquiries", endpoint.method == .post,
                endpoint.headers["Content-Type"] == "application/json"
            else { throw NetworkError.badStatus(404) }
            return ()
        }

        try await RemoteEnquiryRepository(client: client).submit(enquiry(contact: .email("jane@example.com")))
    }

    @Test func emailContactIsSentAsEmailOnly() async throws {
        let dto = EnquiryRequestDTO(enquiry(contact: .email("jane@example.com")))

        let json = try jsonObject(try JSONEncoder().encode(dto))

        #expect(json["email"] as? String == "jane@example.com")
        #expect(json["phone"] == nil)
        #expect(json["productId"] as? Int == 9)
        #expect(json["productTitle"] as? String == "Slim Shirt")
        #expect(json["name"] as? String == "Jane Doe")
        #expect(json["message"] as? String == "Hello")
    }

    @Test func phoneContactIsSentAsPhoneOnly() async throws {
        let dto = EnquiryRequestDTO(enquiry(contact: .phone("+61412345678")))

        let json = try jsonObject(try JSONEncoder().encode(dto))

        #expect(json["phone"] as? String == "+61412345678")
        #expect(json["email"] == nil)
    }

    @Test func propagatesDeliveryFailures() async {
        let client = StubHTTPClient { _ in throw NetworkError.badStatus(500) }

        await #expect(throws: NetworkError.badStatus(500)) {
            try await RemoteEnquiryRepository(client: client).submit(enquiry(contact: .email("jane@example.com")))
        }
    }
}
