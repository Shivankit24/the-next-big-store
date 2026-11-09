//
//  APIConfiguration.swift
//  TheNextBigStore
//
//  Created by Shivankit on 09/11/26.
//

import Foundation

/// Where the backend lives. Injected into the HTTP client so the host can change
/// (local server, staging, production) without touching networking code.
nonisolated struct APIConfiguration: Sendable {
    let baseURL: URL

    /// The locally running NodeJS backend. The port matches the backend's default.
    static let local = APIConfiguration(baseURL: URL(string: "http://localhost:3000")!)
}
