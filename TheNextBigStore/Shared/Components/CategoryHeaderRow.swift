//
//  CategoryHeaderRow.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Tappable row that heads a category. Pinned to the top while its category is on screen.
struct CategoryHeaderRow: View {
    let title: String
    let productCount: Int
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.s) {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(productCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.down")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .padding(.horizontal, Theme.Spacing.l)
            .padding(.vertical, Theme.Spacing.m)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Opaque, so products scrolling underneath the pinned row never show through.
        .background(.bar)
        .overlay(alignment: .bottom) { Divider() }
        .accessibilityValue(isExpanded ? Constants.Category.expanded : Constants.Category.collapsed)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        CategoryHeaderRow(title: "Men's Clothing", productCount: 4, isExpanded: true) {}
        CategoryHeaderRow(title: "Jewelery", productCount: 4, isExpanded: false) {}
    }
}
#endif
