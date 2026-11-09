import Foundation
import Testing
@testable import TheNextBigStore

struct URLSessionHTTPClientTests {
    private struct StubSession: NetworkSession {
        let result: Result<(Data, URLResponse), URLError>

        func load(_ request: URLRequest) async throws -> (Data, URLResponse) {
            try result.get()
        }
    }

    private struct Item: Decodable, Sendable, Equatable {
        let id: Int
    }

    private let url = URL(string: "http://localhost:3000/items")!

    private func makeClient(status: Int = 200, body: String = "[]") -> URLSessionHTTPClient {
        let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
        return URLSessionHTTPClient(session: StubSession(result: .success((Data(body.utf8), response))))
    }

    @Test func decodesSuccessfulResponse() async throws {
        let client = makeClient(body: #"[{"id": 1}, {"id": 2}]"#)

        let items: [Item] = try await client.send(Endpoint(path: "/items"))

        #expect(items == [Item(id: 1), Item(id: 2)])
    }

    @Test func throwsBadStatusForNon2xx() async {
        let client = makeClient(status: 404)

        await #expect(throws: NetworkError.badStatus(404)) {
            let _: [Item] = try await client.send(Endpoint(path: "/items"))
        }
    }

    @Test func throwsInvalidResponseForNonHTTPResponse() async {
        let nonHTTP = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let client = URLSessionHTTPClient(session: StubSession(result: .success((Data(), nonHTTP))))

        await #expect(throws: NetworkError.invalidResponse) {
            let _: [Item] = try await client.send(Endpoint(path: "/items"))
        }
    }

    @Test func throwsDecodingErrorForMalformedBody() async {
        let client = makeClient(body: #"{"unexpected": true}"#)

        await #expect {
            let _: [Item] = try await client.send(Endpoint(path: "/items"))
        } throws: { error in
            guard case NetworkError.decoding = error else { return false }
            return true
        }
    }

    @Test func mapsURLErrorToTransportError() async {
        let client = URLSessionHTTPClient(session: StubSession(result: .failure(URLError(.notConnectedToInternet))))

        await #expect(throws: NetworkError.transport(.notConnectedToInternet)) {
            let _: [Item] = try await client.send(Endpoint(path: "/items"))
        }
    }
}
