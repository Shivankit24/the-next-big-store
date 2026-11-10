//
//  RemoteImageView.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import SwiftUI

/// Shows an image from a URL. Each instance loads independently and renders the moment
/// its own image arrives, fading in from a spinner.
struct RemoteImageView: View {
    let url: URL?

    @Environment(\.imageLoader) private var loader
    @State private var state: LoadState<UIImage> = .idle

    var body: some View {
        ZStack {
            switch state {
            case .loaded(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .transition(.opacity)
            case .failed:
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(.secondary)
            case .idle, .loading:
                ProgressView()
            }
        }
        .task(id: url) { await load() }
    }

    private func load() async {
        guard let url else {
            state = .failed("Missing image URL.")
            return
        }
        if let cached = loader.cachedImage(for: url) {
            state = .loaded(cached)
            return
        }

        state = .loading
        do {
            let image = try await loader.image(for: url)
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.2)) { state = .loaded(image) }
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed(error.localizedDescription)
        }
    }
}

extension EnvironmentValues {
    /// The loader used by every `RemoteImageView`. Injected once at the app root.
    @Entry var imageLoader: any ImageLoading = ImageLoader()
}

#Preview {
    RemoteImageView(url: URL(string: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png"))
        .frame(width: 160, height: 160)
}
