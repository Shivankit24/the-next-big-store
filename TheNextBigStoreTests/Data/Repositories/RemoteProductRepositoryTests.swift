import Foundation
import Testing
@testable import TheNextBigStore

struct RemoteProductRepositoryTests {
    @Test func fetchProductsRequestsProductList() async throws {
        let expected = [Product.fixture(id: 1), Product.fixture(id: 2)]
        let client = StubHTTPClient { endpoint in
            guard endpoint.path == "/products" else { throw NetworkError.badStatus(404) }
            return expected
        }

        let products = try await RemoteProductRepository(client: client).fetchProducts()

        #expect(products == expected)
    }

    @Test func fetchProductRequestsProductById() async throws {
        let expected = Product.fixture(id: 7)
        let client = StubHTTPClient { endpoint in
            guard endpoint.path == "/products/7" else { throw NetworkError.badStatus(404) }
            return expected
        }

        let product = try await RemoteProductRepository(client: client).fetchProduct(id: 7)

        #expect(product == expected)
    }

    @Test func propagatesClientErrors() async {
        let client = StubHTTPClient { _ in throw NetworkError.badStatus(500) }

        await #expect(throws: NetworkError.badStatus(500)) {
            _ = try await RemoteProductRepository(client: client).fetchProducts()
        }
    }
}
