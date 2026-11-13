import Foundation

/// Streams dashboard revisions from `GET /api/dashboard/events` over HTTPS.
public struct URLSessionRevisionStream: RevisionStreamSource {
    public let baseURL: URL
    public let session: URLSession

    public init(baseURL: URL, session: URLSession = Self.makeDefaultSession()) {
        self.baseURL = baseURL
        self.session = session
    }

    public init(configuration: AppConfiguration, session: URLSession = Self.makeDefaultSession()) {
        self.baseURL = configuration.apiBaseURL
        self.session = session
    }

    /// An uncached session whose idle request timeout outlives the server's
    /// 25-second keepalive comment while detecting stalled connections.
    public static func makeDefaultSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 0
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }

    public func connect() -> AsyncThrowingStream<RevisionStreamMessage, any Error> {
        let baseURL = self.baseURL
        let session = self.session
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let request = try Self.makeRequest(baseURL: baseURL)
                    let (bytes, response) = try await session.bytes(for: request)
                    guard let http = response as? HTTPURLResponse else {
                        throw RevisionStreamError.disconnected
                    }
                    guard http.statusCode == 200 else {
                        throw RevisionStreamError.unavailable(retryAfter: Self.retryAfter(from: http))
                    }
                    let contentType = http.value(forHTTPHeaderField: "Content-Type")?.lowercased() ?? ""
                    guard contentType.hasPrefix("text/event-stream") else {
                        throw RevisionStreamError.unavailable(retryAfter: nil)
                    }

                    var decoder = SSEDecoder()
                    for try await byte in bytes {
                        try Task.checkCancellation()
                        guard let event = try decoder.feed(byte) else { continue }
                        if let retry = event.retryMilliseconds {
                            continuation.yield(.retry(milliseconds: retry))
                        }
                        if event.event == nil || event.event == "message",
                            let raw = event.data?.trimmingCharacters(in: .whitespacesAndNewlines),
                            let revision = Int(raw)
                        {
                            continuation.yield(.revision(revision))
                        }
                    }
                    try Task.checkCancellation()
                    continuation.finish(throwing: RevisionStreamError.disconnected)
                } catch is CancellationError {
                    continuation.finish()
                } catch let error as URLError where error.code == .cancelled {
                    continuation.finish()
                } catch let error as RevisionStreamError {
                    continuation.finish(throwing: error)
                } catch {
                    continuation.finish(throwing: RevisionStreamError.disconnected)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    static func makeRequest(baseURL: URL) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw RevisionStreamError.unavailable(retryAfter: nil)
        }
        let basePath =
            components.path.hasSuffix("/")
            ? String(components.path.dropLast())
            : components.path
        components.path = basePath + "/api/dashboard/events"
        components.queryItems = nil
        guard let url = components.url else {
            throw RevisionStreamError.unavailable(retryAfter: nil)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
        request.setValue("identity", forHTTPHeaderField: "Accept-Encoding")
        return request
    }

    private static func retryAfter(from response: HTTPURLResponse) -> TimeInterval? {
        guard
            let raw = response.value(forHTTPHeaderField: "Retry-After")?.trimmingCharacters(in: .whitespaces),
            let seconds = TimeInterval(raw), seconds > 0
        else {
            return nil
        }
        return seconds
    }
}
