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
            "The request could not be created."
        case .transport(let code) where code == .notConnectedToInternet:
            "You appear to be offline. Check your connection and try again."
        case .transport:
            "We couldn't reach the server. Please try again."
        case .invalidResponse, .decoding:
            "We received an unexpected response from the server."
        case .badStatus(let status):
            "The server responded with an error (\(status))."
        }
    }
}
