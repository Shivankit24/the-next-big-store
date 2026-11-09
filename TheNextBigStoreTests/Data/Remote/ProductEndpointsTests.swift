import Foundation
import Testing
@testable import TheNextBigStore

struct ProductEndpointsTests {
    @Test func productsListPath() {
        #expect(Endpoint.products.path == "/products")
        #expect(Endpoint.products.method == .get)
    }

    @Test func singleProductPathIncludesId() {
        #expect(Endpoint.product(id: 4).path == "/products/4")
    }

    @Test func productJSONFromContractDecodes() throws {
        let json = """
        {"id": 4, "title": "Mens Casual Slim Fit", "price": 15.99, "description": "d",
         "category": "men's clothing", "image": "https://fakestoreapi.com/img/71YXzeOuslL._AC_UY879_t.png",
         "rating": {"rate": 2.1, "count": 430}}
        """
        let product = try JSONDecoder().decode(Product.self, from: Data(json.utf8))

        #expect(product.id == 4)
        #expect(product.rating == Rating(rate: 2.1, count: 430))
        #expect(product.imageURL != nil)
    }
}
