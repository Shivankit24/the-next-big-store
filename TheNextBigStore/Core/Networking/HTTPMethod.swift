import Foundation

/// HTTP verbs the app uses.
nonisolated enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}
