//
//  CategoryProductsView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// The body of an expanded category: top rated products, then a clearly separated
/// group of additional products.
struct CategoryProductsView: View {
    let section: CategorySection

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.l) {
            subheading(Constants.Category.topRated)
            ProductGridView(products: section.topRated)

            if !section.additional.isEmpty {
                Divider()
                    .padding(.vertical, Theme.Spacing.s)
                subheading(Constants.Category.moreProducts)
                ProductGridView(products: section.additional)
            }
        }
        .padding(Theme.Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func subheading(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .accessibilityAddTraits(.isHeader)
    }
}

#if DEBUG
#Preview {
    ScrollView {
        CategoryProductsView(
            section: PreviewData.products.groupedByCategory(topRatedLimit: 2)[0]
        )
    }
}
#endif
