//
//  ProductTileView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Product card used on the Home and Category pages:
/// a square image area on top, then title, price and rating.
struct ProductTileView: View {
    let product: Product

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageArea
            details
        }
        .background(.background)
        .clipShape(cardShape)
        .overlay(cardShape.strokeBorder(.separator, lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
    }

    /// Edge-to-edge square so every card has the same image proportions,
    /// with the product inset so it never touches the card's edges.
    private var imageArea: some View {
        Color.white
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                RemoteImageView(url: product.imageURL)
                    .padding(Theme.Spacing.l)
            }
            .clipped()
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(product.title.trimmingCharacters(in: .whitespaces))
                .font(.subheadline.weight(.semibold))
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
            Text(PriceFormatter.string(from: product.price))
                .font(.headline)
            RatingView(rate: product.rating.rate, count: product.rating.count)
                .padding(.top, Theme.Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.m)
    }
}

#if DEBUG
#Preview {
    ProductTileView(product: PreviewData.products[0])
        .frame(width: 180)
        .padding()
}
#endif
