import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct APIClient: Sendable {
  public let baseURL: URL
  public let transport: any APITransport
  public let cache: any ResponseCache

  public init(
    baseURL: URL,
    transport: any APITransport = URLSessionTransport(),
    cache: any ResponseCache = APIClient.defaultCache()
  ) throws {
    guard baseURL.scheme?.lowercased() == "https", baseURL.host?.isEmpty == false else {
      throw AppConfigurationError.invalidAPIBaseURL(baseURL.absoluteString)
    }
    self.baseURL = baseURL
    self.transport = transport
    self.cache = cache
  }

  public init(
    configuration: AppConfiguration,
    transport: any APITransport = URLSessionTransport(),
    cache: any ResponseCache = APIClient.defaultCache()
  ) {
    self.baseURL = configuration.apiBaseURL
    self.transport = transport
    self.cache = cache
  }

  public func send<R: APIRequest>(_ request: R) async throws -> R.Response {
    try request.validate()
    let urlRequest = try makeURLRequest(request)
    let key = urlRequest.url?.absoluteString ?? request.path
    let cachedResponse = await cache.load(key: key)
    var requestWithHeaders = urlRequest
    if let etag = cachedResponse?.etag {
      requestWithHeaders.setValue(etag, forHTTPHeaderField: "If-None-Match")
    }

    let response: TransportResponse
    do {
      try Task.checkCancellation()
      response = try await transport.send(requestWithHeaders)
      try Task.checkCancellation()
    } catch is CancellationError {
      throw APIError.cancelled
    } catch let error as URLError where error.code == .cancelled {
      throw APIError.cancelled
    } catch {
      throw APIError.offline
    }

    if response.statusCode == 304 {
      guard let cachedResponse else {
        throw APIError.http(status: 304)
      }
      do {
        let value = try decodeAndNormalize(cachedResponse.body, as: R.Response.self)
        await cache.save(
          CachedResponse(body: cachedResponse.body, etag: cachedResponse.etag, fetchedAt: Date()),
          key: key
        )
        return value
      } catch let error as APIError {
        await cache.remove(key: key)
        throw error
      } catch {
        await cache.remove(key: key)
        throw APIError.decoding(String(describing: error))
      }
    }

    guard (200...299).contains(response.statusCode) else {
      throw APIError.http(status: response.statusCode)
    }

    do {
      let value = try decodeAndNormalize(response.data, as: R.Response.self)
      let etag = response.headers.first { $0.key.lowercased() == "etag" }?.value
      await cache.save(
        CachedResponse(body: response.data, etag: etag, fetchedAt: Date()),
        key: key
      )
      return value
    } catch let error as APIError {
      throw error
    } catch {
      throw APIError.decoding(String(describing: error))
    }
  }

  public func cached<R: APIRequest>(_ request: R) async -> R.Response? {
    guard let urlRequest = try? makeURLRequest(request),
      let key = urlRequest.url?.absoluteString,
      let response = await cache.load(key: key)
    else {
      return nil
    }

    do {
      return try decodeAndNormalize(response.body, as: R.Response.self)
    } catch {
      await cache.remove(key: key)
      return nil
    }
  }

  public func cachedFetchedAt<R: APIRequest>(_ request: R) async -> Date? {
    guard let urlRequest = try? makeURLRequest(request),
      let key = urlRequest.url?.absoluteString
    else {
      return nil
    }
    return await cache.load(key: key)?.fetchedAt
  }

  public func dashboard(days: Int = 7) async throws -> Dashboard {
    try await send(DashboardRequest(days: days))
  }

  public func health() async throws -> HealthResponse {
    try await send(HealthRequest())
  }

  public func revision() async throws -> RevisionResponse {
    try await send(RevisionRequest())
  }

  public func calendar(_ request: CalendarRequest) async throws -> CalendarPage {
    try await send(request)
  }

  public func posts(_ request: PostsRequest) async throws -> PostArchivePage {
    try await send(request)
  }

  public func videos(_ request: VideosRequest) async throws -> VideoArchivePage {
    try await send(request)
  }

  public func postMonths() async throws -> ArchiveMonthsResponse {
    try await send(PostsMonthsRequest())
  }

  public func videoMonths() async throws -> ArchiveMonthsResponse {
    try await send(VideosMonthsRequest())
  }

  public func worksUploads() async throws -> WorksUploadsResponse {
    try await send(WorksUploadsRequest())
  }

  public var calendarSubscriptionURL: URL {
    baseURL.appendingPathComponent("api/calendar.ics")
  }

  /// Creates the app's cache in the platform caches directory.
  public static func defaultCache() -> any ResponseCache {
    FileResponseCache(directory: FileResponseCache.defaultDirectory(named: "KanoNavi"))
  }

  public func resolveMediaURL(_ value: String?) -> URL? {
    guard let value, let url = URL(string: value) else {
      return nil
    }
    return resolveKanoMediaURL(url, against: baseURL)
  }

  private func makeURLRequest<R: APIRequest>(_ request: R) throws -> URLRequest {
    guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
      throw APIError.http(status: 0)
    }
    let basePath =
      components.path.hasSuffix("/")
      ? String(components.path.dropLast())
      : components.path
    components.path = basePath + request.path
    components.queryItems = request.queryItems
    guard let url = components.url else {
      throw APIError.http(status: 0)
    }
    var result = URLRequest(url: url)
    result.httpMethod = "GET"
    result.setValue("application/json", forHTTPHeaderField: "Accept")
    return result
  }

  private func decodeAndNormalize<Response: APIResponse>(
    _ data: Data,
    as type: Response.Type
  ) throws -> Response {
    let value = try JSONDecoder.kanoNavi().decode(type, from: data)
    try value.validated()
    return value.resolvingMedia(against: baseURL)
  }
}
