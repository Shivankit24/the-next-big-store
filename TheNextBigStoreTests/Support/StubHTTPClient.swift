//
//  StubHTTPClient.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Foundation

@testable import TheNextBigStore

/// Returns whatever `responder` produces for an endpoint, so repositories can be tested
/// without a network. A value of the wrong type is reported as an invalid response.
struct StubHTTPClient: HTTPClient {
    let responder: @Sendable (Endpoint) throws -> Any

    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> Response {
        guard let value = try responder(endpoint) as? Response else {
            throw NetworkError.invalidResponse
        }
        return value
    }

    func send(_ endpoint: Endpoint) async throws {
        _ = try responder(endpoint)
    }
}
