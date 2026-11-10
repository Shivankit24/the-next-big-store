//
//  NetworkError.swift
//  TheNextBigStore
//
//  Created by Shivankit on 09/11/26.
//

import Foundation

/// Everything that can go wrong while talking to the backend, in app-level terms.
nonisolated enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case transport(URLError.Code)
    case invalidResponse
    case badStatus(Int)
    case decoding(String)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            Constants.NetworkErrors.invalidURL
        case .transport(let code) where code == .notConnectedToInternet:
            Constants.NetworkErrors.appearsOffline
        case .transport:
            Constants.NetworkErrors.unableToReachServer
        case .invalidResponse, .decoding:
            Constants.NetworkErrors.unexpectedResponse
        case .badStatus(let status):
            "\(Constants.NetworkErrors.badStatus) \(status)."
        }
    }
}
