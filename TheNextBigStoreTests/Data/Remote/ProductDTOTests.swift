//
//  ProductDTOTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import Foundation
import Testing

@testable import TheNextBigStore

@Suite
struct ProductDTOTests {
    private let contractJSON = """
    {
        "id": 4,
        "title": "Mens Casual Slim Fit",
        "price": 15.99,
        "description": "d",
        "category": "men's clothing",
        "image": "https://fakestoreapi.com/img/71YXzeOuslL._AC_UY879_t.png",
        "rating": { "rate": 2.1, "count": 430 }
    }
    """

    @Test func decodesContractJSON() throws {
        let dto = try JSONDecoder().decode(ProductDTO.self, from: Data(contractJSON.utf8))

        #expect(dto.id == 4)
        #expect(dto.rating.count == 430)
    }

    @Test func mapsToDomainProduct() throws {
        let dto = try JSONDecoder().decode(ProductDTO.self, from: Data(contractJSON.utf8))

        let product = dto.asProduct()

        #expect(product.id == 4)
        #expect(product.title == "Mens Casual Slim Fit")
        #expect(product.price == 15.99)
        #expect(product.rating == Rating(rate: 2.1, count: 430))
        #expect(product.imageURL?.absoluteString == "https://fakestoreapi.com/img/71YXzeOuslL._AC_UY879_t.png")
    }

    @Test func trimsWhitespaceAroundTitle() {
        let product = ProductDTO.fixture(title: "Mens Casual Premium Slim Fit T-Shirts ").asProduct()

        #expect(product.title == "Mens Casual Premium Slim Fit T-Shirts")
    }

    @Test func emptyImageStringMapsToNoURL() {
        #expect(ProductDTO.fixture(image: "").asProduct().imageURL == nil)
    }
}

extension ProductDTO {
    static func fixture(
        id: Int = 1,
        title: String = "Item",
        category: String = "men's clothing",
        image: String = "https://example.com/1.png"
    ) -> ProductDTO {
        ProductDTO(
            id: id,
            title: title,
            price: 10,
            description: "Description",
            category: category,
            image: image,
            rating: RatingDTO(rate: 4, count: 100)
        )
    }
}
