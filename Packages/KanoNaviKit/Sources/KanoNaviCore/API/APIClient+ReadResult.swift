import Foundation

extension APIClient {
    /// Reads a request from the service. When that fails and a readable
    /// response is cached, returns the cached response marked `isFromCache`
    /// with its fetch time; otherwise rethrows the service's error.
    ///
    /// Cancellation and an invalid request are never answered from the
    /// cache: they throw `APIError.cancelled` and the validation error.
    /// The cached response of a request, marked `isFromCache` with its fetch
    /// time, read on the caller's thread without waiting, so a screen can
    /// show it on its first frame; `nil` when the cache has nothing readable
    /// it can answer at once. See `ResponseCache.loadImmediately(key:)`.
    public func cachedResultImmediately<R: APIRequest>(_ request: R) -> ReadResult<R.Response>? {
        cachedValueImmediately(request).map {
            ReadResult(value: $0.value, isFromCache: true, fetchedAt: $0.fetchedAt)
        }
    }

    public func readResult<R: APIRequest>(_ request: R) async throws -> ReadResult<R.Response> {
        do {
            let value = try await send(request)
            return ReadResult(value: value, isFromCache: false, fetchedAt: Date())
        } catch APIError.cancelled {
            throw APIError.cancelled
        } catch let error as RequestValidationError {
            throw error
        } catch {
            guard Task.isCancelled == false else { throw APIError.cancelled }
            guard let cached = await cachedValue(request) else { throw error }
            return ReadResult(value: cached.value, isFromCache: true, fetchedAt: cached.fetchedAt)
        }
    }
}
