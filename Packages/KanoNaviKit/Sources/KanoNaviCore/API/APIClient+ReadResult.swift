import Foundation

extension APIClient {
    /// Reads a request from the service. When that fails and a readable
    /// response is cached, returns the cached response marked `isFromCache`
    /// with its fetch time; otherwise rethrows the service's error.
    ///
    /// Cancellation and an invalid request are never answered from the
    /// cache: they throw `APIError.cancelled` and the validation error.
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
