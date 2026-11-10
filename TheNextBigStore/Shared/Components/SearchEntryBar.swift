//
//  SearchEntryBar.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Search-bar lookalike that opens the Search page when tapped. It matches the real
/// bar's shape and height so the hand-off feels continuous.
struct SearchEntryBar: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.s) {
                Image(systemName: "magnifyingglass")
                Text(Constants.Search.placeholder)
                Spacer()
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, Theme.Spacing.l)
            .frame(height: 44)
            .background(Color(.tertiarySystemFill), in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Constants.Search.placeholder)
        .accessibilityAddTraits(.isSearchField)
    }
}

#if DEBUG
#Preview {
    SearchEntryBar {}
        .padding()
}
#endif
