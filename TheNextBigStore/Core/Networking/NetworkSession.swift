//
//  NetworkSession.swift
//  TheNextBigStore
//
//  Created by Shivankit on 09/11/26.
//

import Foundation

/// The single capability the HTTP client needs from `URLSession`.
/// Abstracted so tests can supply canned responses without touching the network.
nonisolated protocol NetworkSession: Sendable {
    func load(_ request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {
    nonisolated func load(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}
