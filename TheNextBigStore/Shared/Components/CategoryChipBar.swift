//
//  CategoryChipBar.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Horizontally scrolling strip of category chips with exactly one selected.
/// Stays pinned above the content it controls and keeps the selected chip in view.
struct CategoryChipBar: View {
    struct Item: Identifiable, Equatable {
        let id: String
        let title: String
    }

    let items: [Item]
    let selectedID: String?
    let onSelect: (String) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.s) {
                    ForEach(items) { item in
                        chip(for: item)
                            .id(item.id)
                    }
                }
                .padding(.horizontal, Theme.Spacing.l)
                .padding(.vertical, Theme.Spacing.s)
            }
            .onChange(of: selectedID) { _, newID in
                guard let newID else { return }
                withAnimation(.snappy(duration: 0.25)) {
                    proxy.scrollTo(newID, anchor: .center)
                }
            }
        }
        // Opaque, so content scrolling underneath never shows through.
        .background(.bar)
        .overlay(alignment: .bottom) { Divider() }
        .sensoryFeedback(.selection, trigger: selectedID)
    }

    private func chip(for item: Item) -> some View {
        let isSelected = item.id == selectedID
        return Button {
            onSelect(item.id)
        } label: {
            Text(item.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, Theme.Spacing.l)
                .padding(.vertical, Theme.Spacing.s)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill), in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.2), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selected: String? = "electronics"
    CategoryChipBar(
        items: [
            .init(id: "electronics", title: "Electronics"),
            .init(id: "jewelery", title: "Jewelery"),
            .init(id: "men", title: "Men's Clothing"),
            .init(id: "women", title: "Women's Clothing"),
        ],
        selectedID: selected
    ) { selected = $0 }
}
#endif
