import Foundation

/// Fetches image files from the media route with a session of its own.
///
/// Archive files are immutable (`Cache-Control: max-age=31536000,
/// immutable`), so the session's disk cache answers a file it has seen
/// without asking the server again.
nonisolated struct MediaImageDownload: Sendable {
    let session: URLSession

    /// Room on disk for the fetched files: an archive of a few hundred
    /// megabytes. The system removes the oldest files beyond it, and may
    /// empty the caches directory when the device runs short of space.
    static let diskCapacity = 512 * 1024 * 1024

    /// The app's image session: its own disk cache in the caches directory,
    /// no cookies and no credentials.
    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        let directory = URL.cachesDirectory.appending(
            path: "KanoNaviMediaImages", directoryHint: .isDirectory)
        // Decoded images have their own memory cache; this one holds bytes
        // only briefly on their way to disk.
        configuration.urlCache = URLCache(
            memoryCapacity: 8 * 1024 * 1024, diskCapacity: diskCapacity, directory: directory)
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        configuration.urlCredentialStorage = nil
        configuration.timeoutIntervalForRequest = 30
        return URLSession(configuration: configuration)
    }

    /// The bytes of the file at `url`. A missing file (404 or 410) is
    /// `MediaImageError.unavailable`; any other failure is `.failed`, except
    /// cancellation, which is `CancellationError`.
    func data(from url: URL) async throws -> Data {
        guard url.scheme?.lowercased() == "https" else { throw MediaImageError.unavailable }
        var request = URLRequest(url: url)
        request.setValue("image/*", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            throw MediaImageError.failed
        }

        guard let http = response as? HTTPURLResponse else { throw MediaImageError.failed }
        switch http.statusCode {
        case 200...299: return data
        case 404, 410: throw MediaImageError.unavailable
        default: throw MediaImageError.failed
        }
    }
}
