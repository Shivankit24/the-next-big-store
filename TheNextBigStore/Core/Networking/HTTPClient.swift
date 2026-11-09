import Foundation

/// Sends endpoints to the backend and decodes the JSON response.
nonisolated protocol HTTPClient: Sendable {
    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> Response
}

/// `HTTPClient` backed by `URLSession`.
nonisolated struct URLSessionHTTPClient: HTTPClient {
    private let configuration: APIConfiguration
    private let session: any NetworkSession

    init(configuration: APIConfiguration = .local, session: any NetworkSession = URLSession.shared) {
        self.configuration = configuration
        self.session = session
    }

    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> Response {
        let request = try endpoint.urlRequest(baseURL: configuration.baseURL)
        let (data, response) = try await perform(request)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.badStatus(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw NetworkError.decoding(String(describing: error))
        }
    }

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.load(request)
        } catch let error as URLError {
            throw NetworkError.transport(error.code)
        }
    }
}
