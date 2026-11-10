//
//  ProductGridView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Adaptive grid of product tiles, shared by every page that lists products.
struct ProductGridView: View {
    let products: [Product]

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: Theme.Spacing.l, alignment: .top)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.l) {
            ForEach(products) { product in
                ProductTileView(product: product)
            }
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        ProductGridView(products: PreviewData.products)
            .padding(Theme.Spacing.l)
    }
}
#endif
