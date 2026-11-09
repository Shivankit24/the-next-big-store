//
//  PreviewData.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

#if DEBUG
import Foundation

/// Sample data for SwiftUI previews only. Compiled out of release builds.
nonisolated enum PreviewData {
    static let products: [Product] = [
        make(1, "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops", 109.95, "men's clothing", 3.9, 120),
        make(2, "Mens Casual Premium Slim Fit T-Shirts ", 22.3, "men's clothing", 4.1, 259),
        make(3, "Mens Cotton Jacket", 55.99, "men's clothing", 4.7, 500),
        make(4, "Mens Casual Slim Fit", 15.99, "men's clothing", 2.1, 430),
        make(5, "John Hardy Women's Legends Naga Gold & Silver Dragon Station Chain Bracelet", 695, "jewelery", 4.6, 400),
        make(6, "Solid Gold Petite Micropave", 168, "jewelery", 3.9, 70),
    ]

    private static func make(
        _ id: Int, _ title: String, _ price: Double, _ category: String, _ rate: Double, _ count: Int
    ) -> Product {
        Product(
            id: id,
            title: title,
            price: price,
            description: "Preview description",
            category: category,
            image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png",
            rating: Rating(rate: rate, count: count)
        )
    }
}

/// Repository that serves `PreviewData`, so previews never touch the network.
nonisolated struct PreviewProductRepository: ProductRepository {
    var products: [Product] = PreviewData.products

    func fetchProducts() async throws -> [Product] { products }

    func fetchProduct(id: Int) async throws -> Product {
        guard let product = products.first(where: { $0.id == id }) else {
            throw NetworkError.badStatus(404)
        }
        return product
    }
}
#endif
