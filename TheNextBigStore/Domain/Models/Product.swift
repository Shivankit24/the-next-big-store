import Foundation

/// A catalogue product.
///
/// Mirrors the product contract exposed by the backend (see `api_contract_data_models.md`).
/// Kept free of any UI or networking concerns so the data source can change without touching it.
nonisolated struct Product: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating

    /// The product image as a URL, or `nil` if the backend sent a malformed string.
    var imageURL: URL? { URL(string: image) }
}
