//
//  ProductDetailsView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Everything known about a product, with a prominent Enquire button pinned to the bottom.
struct ProductDetailsView: View {
    let product: Product

    @Environment(\.enquiryViewModelFactory) private var enquiryViewModelFactory
    @State private var isEnquiryPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                image

                VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                    Text(product.category.name)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(product.title)
                        .font(.title2.bold())
                    HStack(spacing: Theme.Spacing.s) {
                        RatingView(rate: product.rating.rate, count: product.rating.count)
                        Text(Constants.ProductDetails.ratingValue(product.rating.rate))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(PriceFormatter.string(from: product.price))
                        .font(.title.bold())
                        .padding(.top, Theme.Spacing.xs)
                }

                Divider()

                VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                    Text(Constants.ProductDetails.description)
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Text(product.description)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(Theme.Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { enquireBar }
        // Root pages hide the navigation bar; this page needs it for the back button.
        .toolbarVisibility(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEnquiryPresented) {
            EnquiryFormView(viewModel: enquiryViewModelFactory.make(for: product))
        }
    }

    private var image: some View {
        Color.white
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                RemoteImageView(url: product.imageURL)
                    .padding(Theme.Spacing.l)
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .strokeBorder(.separator, lineWidth: 0.5)
            )
    }

    private var enquireBar: some View {
        Button {
            isEnquiryPresented = true
        } label: {
            Text(Constants.ProductDetails.enquire)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.s)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(Theme.Spacing.l)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ProductDetailsView(product: PreviewData.products[0])
    }
}
#endif
