//
//  ImageLoaderTests.swift
//  TheNextBigStoreTests
//
//  Created by Shivankit on 10/11/26.
//

import UIKit
import Testing

@testable import TheNextBigStore

@Suite
struct ImageLoaderTests {
    /// Serves one canned response and counts requests. The short delay lets
    /// concurrent callers overlap so request sharing can be observed.
    private struct CountingSession: NetworkSession {
        var data = ImageLoaderTests.pngData()
        var status = 200
        let requests = CallCounter()

        func load(_ request: URLRequest) async throws -> (Data, URLResponse) {
            await requests.increment()
            try await Task.sleep(for: .milliseconds(50))
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
    }

    private static func pngData() -> Data {
        let size = CGSize(width: 4, height: 4)
        return UIGraphicsImageRenderer(size: size).pngData { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private let url = URL(string: "https://example.com/image.png")!

    @Test func downloadsAndDecodesImage() async throws {
        let loader = ImageLoader(session: CountingSession())

        let image = try await loader.image(for: url)

        #expect(image.size.width > 0)
    }

    @Test func secondLoadComesFromCache() async throws {
        let session = CountingSession()
        let loader = ImageLoader(session: session)

        #expect(loader.cachedImage(for: url) == nil)
        _ = try await loader.image(for: url)
        _ = try await loader.image(for: url)

        #expect(loader.cachedImage(for: url) != nil)
        #expect(await session.requests.value == 1)
    }

    @Test func concurrentRequestsForSameURLShareOneDownload() async throws {
        let session = CountingSession()
        let loader = ImageLoader(session: session)

        async let first = loader.image(for: url)
        async let second = loader.image(for: url)
        _ = try await (first, second)

        #expect(await session.requests.value == 1)
    }

    @Test func differentURLsDownloadSeparately() async throws {
        let session = CountingSession()
        let loader = ImageLoader(session: session)

        _ = try await loader.image(for: url)
        _ = try await loader.image(for: URL(string: "https://example.com/other.png")!)

        #expect(await session.requests.value == 2)
    }

    @Test func badStatusThrows() async {
        let loader = ImageLoader(session: CountingSession(status: 404))

        await #expect(throws: NetworkError.badStatus(404)) {
            _ = try await loader.image(for: url)
        }
    }

    @Test func undecodableDataThrows() async {
        let loader = ImageLoader(session: CountingSession(data: Data("not an image".utf8)))

        await #expect {
            _ = try await loader.image(for: url)
        } throws: { error in
            guard case NetworkError.decoding = error else { return false }
            return true
        }
    }

    @Test func failedDownloadIsNotCached() async {
        let loader = ImageLoader(session: CountingSession(status: 500))

        _ = try? await loader.image(for: url)

        #expect(loader.cachedImage(for: url) == nil)
    }
}
