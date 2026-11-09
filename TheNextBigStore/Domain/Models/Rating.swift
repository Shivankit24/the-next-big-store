import Foundation

/// Aggregate customer rating for a product.
nonisolated struct Rating: Codable, Equatable, Hashable, Sendable {
    /// Average rating out of 5.
    let rate: Double
    /// Total number of ratings received.
    let count: Int
}
