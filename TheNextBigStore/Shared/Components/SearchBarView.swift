//
//  SearchBarView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Text field with two clearly different trailing controls:
/// a small grey "x" that empties the field (shown only when there is text), and a filled
/// magnifying-glass button that runs the search (enabled only when there is something to
/// search for). Typing never searches by itself.
struct SearchBarView: View {
    @Binding var text: String
    let canSearch: Bool
    let onSearch: () -> Void
    let onClear: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 0) {
            TextField(Constants.Search.placeholder, text: $text)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit(performSearch)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.leading, Theme.Spacing.l)

            if !text.isEmpty {
                Button {
                    onClear()
                    isFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .transition(.opacity)
                .accessibilityLabel(Constants.Search.clearLabel)
            }

            Button(action: performSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 36)
                    .background(canSearch ? Color.accentColor : Color.secondary.opacity(0.35), in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!canSearch)
            .padding(4)
            .accessibilityLabel(Constants.Search.searchLabel)
        }
        .frame(height: 44)
        .background(Color(.tertiarySystemFill), in: Capsule())
        .animation(.snappy(duration: 0.15), value: text.isEmpty)
        .animation(.snappy(duration: 0.15), value: canSearch)
        // Takes the keyboard as soon as the bar appears, so the page opens ready to type.
        .task { isFocused = true }
    }

    private func performSearch() {
        guard canSearch else { return }
        isFocused = false
        onSearch()
    }
}

#if DEBUG
#Preview {
    @Previewable @State var text = "shirt"
    SearchBarView(text: $text, canSearch: !text.isEmpty, onSearch: {}, onClear: { text = "" })
        .padding()
}
#endif
