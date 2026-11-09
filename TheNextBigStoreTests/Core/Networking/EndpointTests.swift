//
//  EndpointTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 09/11/26.
//

import Foundation
import Testing

@testable import TheNextBigStore

@Suite
struct EndpointTests {
    private let baseURL = URL(string: "http://localhost:3000")!

    @Test func buildsGetRequestWithPath() throws {
        let request = try Endpoint(path: "/products").urlRequest(baseURL: baseURL)

        #expect(request.url?.absoluteString == "http://localhost:3000/products")
        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
    }

    @Test func appendsQueryItems() throws {
        let endpoint = Endpoint(path: "/products", queryItems: [URLQueryItem(name: "q", value: "shirt")])
        let request = try endpoint.urlRequest(baseURL: baseURL)

        #expect(request.url?.absoluteString == "http://localhost:3000/products?q=shirt")
    }

    @Test func appliesMethodHeadersAndBody() throws {
        let body = Data("{}".utf8)
        let endpoint = Endpoint(
            path: "/products",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: body
        )
        let request = try endpoint.urlRequest(baseURL: baseURL)

        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.httpBody == body)
    }
}
