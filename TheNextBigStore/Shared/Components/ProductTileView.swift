//
//  ProductTileView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Compact product summary used on the Home and Category pages:
/// image, title, price and rating.
struct ProductTileView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            image
            Text(product.title.trimmingCharacters(in: .whitespaces))
                .font(.headline)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
            Text(PriceFormatter.string(from: product.price))
                .font(.title3.bold())
            RatingView(rate: product.rating.rate, count: product.rating.count)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private var image: some View {
        AsyncImage(url: product.imageURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary)
            default:
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .padding(8)
        .background(.white, in: RoundedRectangle(cornerRadius: 12))
    }
}

#if DEBUG
#Preview {
    ProductTileView(product: PreviewData.products[0])
        .frame(width: 180)
        .padding()
}
#endif
