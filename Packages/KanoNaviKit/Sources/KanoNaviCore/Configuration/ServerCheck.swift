import Foundation

/// Confirms that an address serves a Kano Navi service the app can read
/// before it is added.
public enum ServerCheck {
    /// Reads one day of the dashboard from `baseURL`, which must decode with
    /// the projection version the app requires. Nothing is cached.
    public static func verify(
        _ baseURL: URL, transport: any APITransport = URLSessionTransport()
    ) async throws(ServerCheckError) {
        let client: APIClient
        do {
            client = try APIClient(baseURL: baseURL, transport: transport, cache: MemoryResponseCache())
        } catch {
            throw .incompatible
        }

        do {
            _ = try await client.dashboard(days: 1)
        } catch APIError.offline {
            throw .unreachable
        } catch APIError.cancelled {
            throw .cancelled
        } catch {
            throw .incompatible
        }
    }
}
