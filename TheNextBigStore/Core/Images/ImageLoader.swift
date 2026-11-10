//
//  ImageLoader.swift
//  TheNextBigStore
//
//  Created by Shivankit on 10/11/26.
//

import UIKit

/// In-memory cached image loader.
///
/// Every caller gets its image as soon as that image is ready, independent of the others.
/// Concurrent requests for the same URL share a single download.
actor ImageLoader: ImageLoading {
    private let session: any NetworkSession
    // `NSCache` is documented as thread-safe, which is what lets `cachedImage(for:)` be synchronous.
    private nonisolated(unsafe) let cache = NSCache<NSURL, UIImage>()
    private var inFlight: [URL: Task<UIImage, Error>] = [:]

    init(session: any NetworkSession = URLSession.shared) {
        self.session = session
    }

    nonisolated func cachedImage(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func image(for url: URL) async throws -> UIImage {
        if let cached = cachedImage(for: url) { return cached }
        if let download = inFlight[url] { return try await download.value }

        let download = Task { try await self.download(url) }
        inFlight[url] = download
        defer { inFlight[url] = nil }
        return try await download.value
    }

    private func download(_ url: URL) async throws -> UIImage {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.load(URLRequest(url: url))
        } catch let error as URLError {
            throw NetworkError.transport(error.code)
        }

        guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw NetworkError.badStatus(http.statusCode) }
        guard let image = UIImage(data: data) else {
            throw NetworkError.decoding("Image data could not be decoded.")
        }

        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}
