import Foundation
import Synchronization

/// What the stubbed media route answers, per file address. The last reply
/// of a queue repeats; an address without replies fails as unreachable.
nonisolated final class StubMediaServer: Sendable {
    enum Reply: Sendable {
        case response(status: Int, body: Data, headers: [String: String] = [:])
        case failure(URLError.Code)
    }

    private struct State {
        var replies: [URL: [Reply]] = [:]
        var requests: [URL: [URLRequest]] = [:]
    }

    static let shared = StubMediaServer()
    private let state = Mutex(State())

    /// A session whose requests are answered by the stub and never leave
    /// the process.
    static func session() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubMediaProtocol.self]
        return URLSession(configuration: configuration)
    }

    func stub(_ url: URL, _ replies: Reply...) {
        state.withLock { $0.replies[url] = replies }
    }

    /// The requests received for `url`, in order.
    func requests(to url: URL) -> [URLRequest] {
        state.withLock { $0.requests[url] ?? [] }
    }

    func reply(to request: URLRequest) -> Reply {
        guard let url = request.url else { return .failure(.badURL) }
        return state.withLock { state in
            state.requests[url, default: []].append(request)
            guard var queue = state.replies[url], let first = queue.first else {
                return .failure(.cannotConnectToHost)
            }
            if queue.count > 1 {
                queue.removeFirst()
                state.replies[url] = queue
            }
            return first
        }
    }
}
