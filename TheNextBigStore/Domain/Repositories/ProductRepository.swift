import Foundation

/// Source of catalogue products. Features depend on this protocol only, so the
/// underlying data source (Fake Store via the Node server today) can be replaced.
nonisolated protocol ProductRepository: Sendable {
    func fetchProducts() async throws -> [Product]
    func fetchProduct(id: Int) async throws -> Product
}
