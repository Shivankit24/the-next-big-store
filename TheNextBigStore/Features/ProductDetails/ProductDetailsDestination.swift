//
//  ProductDetailsDestination.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

extension View {
    /// Lets any product tile inside this navigation stack push the product details page.
    /// Add it once per `NavigationStack`.
    func productDetailsDestination() -> some View {
        navigationDestination(for: Product.self) { product in
            ProductDetailsView(product: product)
        }
    }
}
