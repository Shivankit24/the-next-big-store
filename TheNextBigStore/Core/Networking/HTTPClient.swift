//
//  HTTPClient.swift
//  TheNextBigStore
//
//  Created by Shivankit on 09/11/26.
//

import Foundation

/// Sends endpoints to the backend.
nonisolated protocol HTTPClient: Sendable {
    /// Sends the endpoint and decodes the JSON response.
    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> Response

    /// Sends the endpoint and succeeds on any 2xx status, ignoring the response body.
    func send(_ endpoint: Endpoint) async throws
}

/// `HTTPClient` backed by `URLSession`.
nonisolated struct URLSessionHTTPClient: HTTPClient {
    private let configuration: APIConfiguration
    private let session: any NetworkSession

    init(configuration: APIConfiguration = .local, session: any NetworkSession = URLSession.shared) {
        self.configuration = configuration
        self.session = session
    }

    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> Response {
        let data = try await successfulData(for: endpoint)
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw NetworkError.decoding(String(describing: error))
        }
    }

    func send(_ endpoint: Endpoint) async throws {
        _ = try await successfulData(for: endpoint)
    }

    private func successfulData(for endpoint: Endpoint) async throws -> Data {
        let request = try endpoint.urlRequest(baseURL: configuration.baseURL)
        let (data, response) = try await perform(request)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.badStatus(http.statusCode)
        }
        return data
    }

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.load(request)
        } catch let error as URLError {
            throw NetworkError.transport(error.code)
        }
    }
}
