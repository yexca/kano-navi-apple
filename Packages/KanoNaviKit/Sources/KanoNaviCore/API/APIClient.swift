import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct TransportResponse: Sendable {
    public var data: Data
    public var statusCode: Int
    public var headers: [String: String]
    public init(data: Data, statusCode: Int, headers: [String: String] = [:]) { self.data = data; self.statusCode = statusCode; self.headers = headers }
}

public protocol APITransport: Sendable {
    func send(_ request: URLRequest) async throws -> TransportResponse
}

public struct ClosureTransport: APITransport {
    private let handler: @Sendable (URLRequest) async throws -> TransportResponse
    public init(handler: @escaping @Sendable (URLRequest) async throws -> TransportResponse) { self.handler = handler }
    public func send(_ request: URLRequest) async throws -> TransportResponse { try await handler(request) }
}

public struct URLSessionTransport: APITransport {
    public var session: URLSession
    public init(session: URLSession = .shared) { self.session = session }
    public func send(_ request: URLRequest) async throws -> TransportResponse {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        var headers: [String: String] = [:]
        for (key, value) in http.allHeaderFields { if let key = key as? String { headers[key.lowercased()] = String(describing: value) } }
        return TransportResponse(data: data, statusCode: http.statusCode, headers: headers)
    }
}

public struct APIClient: Sendable {
    public let baseURL: URL
    public let transport: any APITransport
    public let cache: any ResponseCache

    public init(baseURL: URL, transport: any APITransport = URLSessionTransport(), cache: any ResponseCache = FileResponseCache(directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("KanoNavi") ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KanoNavi"))) throws {
        guard baseURL.scheme?.lowercased() == "https", baseURL.host?.isEmpty == false else { throw AppConfigurationError.invalidAPIBaseURL(baseURL.absoluteString) }
        self.baseURL = baseURL; self.transport = transport; self.cache = cache
    }

    public init(configuration: AppConfiguration, transport: any APITransport = URLSessionTransport(), cache: any ResponseCache = FileResponseCache(directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("KanoNavi") ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KanoNavi"))) {
        self.baseURL = configuration.apiBaseURL; self.transport = transport; self.cache = cache
    }

    public func send<R: APIRequest>(_ request: R) async throws -> R.Response {
        do { try request.validate() } catch { throw error }
        let urlRequest = try makeURLRequest(request)
        let key = urlRequest.url?.absoluteString ?? request.path
        let cached = await cache.load(key: key)
        var urlRequestWithHeaders = urlRequest
        if let etag = cached?.etag { urlRequestWithHeaders.setValue(etag, forHTTPHeaderField: "If-None-Match") }
        let response: TransportResponse
        do {
            try Task.checkCancellation()
            response = try await transport.send(urlRequestWithHeaders)
            try Task.checkCancellation()
        }
        catch is CancellationError { throw APIError.cancelled }
        catch let error as URLError where error.code == .cancelled { throw APIError.cancelled }
        catch { throw APIError.offline }

        if response.statusCode == 304 {
            guard let cached else { throw APIError.http(status: 304) }
            do {
                await cache.save(CachedResponse(body: cached.body, etag: cached.etag, fetchedAt: Date()), key: key)
                return try decode(cached.body, as: R.Response.self)
            }
            catch { await cache.remove(key: key); throw APIError.decoding(String(describing: error)) }
        }
        guard (200...299).contains(response.statusCode) else { throw APIError.http(status: response.statusCode) }
        do {
            var value = try decode(response.data, as: R.Response.self)
            if var dashboard = value as? Dashboard {
                guard dashboard.projection?.version == 1, dashboard.events.allSatisfy({ $0.view != nil }), dashboard.videos.allSatisfy({ $0.view != nil }) else { throw APIError.incompatible }
                resolveURLs(in: &dashboard)
                guard let converted = dashboard as? R.Response else { throw APIError.decoding("Response type mismatch") }
                value = converted
            } else if var page = value as? CalendarPage {
                guard page.events.allSatisfy({ $0.view != nil }) else { throw APIError.incompatible }
                resolveURLs(in: &page)
                guard let converted = page as? R.Response else { throw APIError.decoding("Response type mismatch") }
                value = converted
            } else if var page = value as? PostArchivePage {
                resolveURLs(in: &page)
                guard let converted = page as? R.Response else { throw APIError.decoding("Response type mismatch") }
                value = converted
            } else if var page = value as? VideoArchivePage {
                resolveURLs(in: &page)
                guard let converted = page as? R.Response else { throw APIError.decoding("Response type mismatch") }
                value = converted
            } else if var uploads = value as? WorksUploadsResponse {
                resolveURLs(in: &uploads)
                guard let converted = uploads as? R.Response else { throw APIError.decoding("Response type mismatch") }
                value = converted
            }
            let etag = response.headers.first(where: { $0.key.lowercased() == "etag" })?.value
            await cache.save(CachedResponse(body: response.data, etag: etag, fetchedAt: Date()), key: key)
            return value
        } catch let error as APIError { throw error }
        catch { throw APIError.decoding(String(describing: error)) }
    }

    public func cached<R: APIRequest>(_ request: R) async -> R.Response? {
        let key = (try? makeURLRequest(request).url?.absoluteString) ?? nil
        guard let key, let cached = await cache.load(key: key) else { return nil }
        do {
            var value = try decode(cached.body, as: R.Response.self)
            if var dashboard = value as? Dashboard {
                guard dashboard.projection?.version == 1, dashboard.events.allSatisfy({ $0.view != nil }), dashboard.videos.allSatisfy({ $0.view != nil }) else { await cache.remove(key: key); return nil }
                resolveURLs(in: &dashboard)
                if let converted = dashboard as? R.Response { value = converted } else { await cache.remove(key: key); return nil }
            } else if var page = value as? CalendarPage {
                guard page.events.allSatisfy({ $0.view != nil }) else { await cache.remove(key: key); return nil }
                resolveURLs(in: &page)
                if let converted = page as? R.Response { value = converted } else { await cache.remove(key: key); return nil }
            } else if var page = value as? PostArchivePage {
                resolveURLs(in: &page)
                if let converted = page as? R.Response { value = converted } else { await cache.remove(key: key); return nil }
            } else if var page = value as? VideoArchivePage {
                resolveURLs(in: &page)
                if let converted = page as? R.Response { value = converted } else { await cache.remove(key: key); return nil }
            } else if var uploads = value as? WorksUploadsResponse {
                resolveURLs(in: &uploads)
                if let converted = uploads as? R.Response { value = converted } else { await cache.remove(key: key); return nil }
            }
            return value
        } catch { await cache.remove(key: key); return nil }
    }

    public func cachedFetchedAt<R: APIRequest>(_ request: R) async -> Date? {
        guard let url = try? makeURLRequest(request), let key = url.url?.absoluteString else { return nil }
        return await cache.load(key: key)?.fetchedAt
    }

    public func dashboard(days: Int = 7) async throws -> Dashboard { try await send(DashboardRequest(days: days)) }
    public func health() async throws -> HealthResponse { try await send(HealthRequest()) }
    public func revision() async throws -> RevisionResponse { try await send(RevisionRequest()) }
    public func calendar(_ request: CalendarRequest) async throws -> CalendarPage { try await send(request) }
    public func posts(_ request: PostsRequest) async throws -> PostArchivePage { try await send(request) }
    public func videos(_ request: VideosRequest) async throws -> VideoArchivePage { try await send(request) }
    public func postMonths() async throws -> ArchiveMonthsResponse { try await send(PostsMonthsRequest()) }
    public func videoMonths() async throws -> ArchiveMonthsResponse { try await send(VideosMonthsRequest()) }
    public func worksUploads() async throws -> WorksUploadsResponse { try await send(WorksUploadsRequest()) }
    public var calendarSubscriptionURL: URL { baseURL.appendingPathComponent("api/calendar.ics") }

    public func resolveMediaURL(_ value: String?) -> URL? {
        guard let value, let url = URL(string: value) else { return nil }
        if url.scheme != nil { return url }
        return URL(string: value, relativeTo: baseURL)?.absoluteURL
    }

    private func makeURLRequest<R: APIRequest>(_ request: R) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else { throw APIError.http(status: 0) }
        let basePath = components.path.hasSuffix("/") ? String(components.path.dropLast()) : components.path
        components.path = basePath + request.path
        components.queryItems = request.queryItems
        guard let url = components.url else { throw APIError.http(status: 0) }
        var result = URLRequest(url: url); result.httpMethod = "GET"; result.setValue("application/json", forHTTPHeaderField: "Accept"); return result
    }

    private func decode<R: Decodable>(_ data: Data, as type: R.Type) throws -> R { try JSONDecoder.kanoNavi().decode(type, from: data) }

    private func resolveURLs(in dashboard: inout Dashboard) {
        dashboard.profile.avatarURL = resolveMediaURL(dashboard.profile.avatarURL?.absoluteString)
        dashboard.profile.bannerURL = resolveMediaURL(dashboard.profile.bannerURL?.absoluteString)
        dashboard.posts = dashboard.posts.map { resolve($0) }
        dashboard.events = dashboard.events.map { resolve($0) }
        dashboard.videos = dashboard.videos.map { resolve($0) }
        dashboard.focus = dashboard.focus.map { resolve($0) }
        dashboard.assets = dashboard.assets.map { resolve($0) }
        dashboard.scheduleImages = dashboard.scheduleImages.map { resolve($0) }
    }

    private func resolve(_ post: Post) -> Post { var value = post; value.url = resolveMediaURL(value.url.absoluteString) ?? value.url; value.accountURL = resolveMediaURL(value.accountURL?.absoluteString); value.mediaURL = resolveMediaURL(value.mediaURL?.absoluteString); value.media = value.media.map { resolve($0) }; return value }
    private func resolve(_ item: MediaItem) -> MediaItem { var value = item; value.url = resolveMediaURL(value.url?.absoluteString); value.sourceURL = resolveMediaURL(value.sourceURL?.absoluteString); return value }
    private func resolve(_ event: ScheduleEvent) -> ScheduleEvent { var value = event; value.url = resolveMediaURL(value.url?.absoluteString); value.liveURL = resolveMediaURL(value.liveURL?.absoluteString); value.links = value.links?.map { var link = $0; link.url = resolveMediaURL(link.url?.absoluteString); return link }; return value }
    private func resolve(_ video: Video) -> Video { var value = video; value.url = resolveMediaURL(value.url.absoluteString) ?? value.url; value.thumbnailURL = resolveMediaURL(value.thumbnailURL?.absoluteString); value.alternates = value.alternates?.map { var alternate = $0; alternate.url = resolveMediaURL(alternate.url.absoluteString) ?? alternate.url; return alternate }; return value }
    private func resolve(_ focus: FocusResource) -> FocusResource { var value = focus; value.imageURL = resolveMediaURL(value.imageURL?.absoluteString); value.url = resolveMediaURL(value.url?.absoluteString); value.sourceURL = resolveMediaURL(value.sourceURL?.absoluteString); return value }
    private func resolve(_ asset: ScheduleAsset) -> ScheduleAsset { var value = asset; value.url = resolveMediaURL(value.url?.absoluteString); value.sourceURL = resolveMediaURL(value.sourceURL?.absoluteString); return value }
    private func resolveURLs(in page: inout CalendarPage) { page.events = page.events.map { resolve($0) }; page.scheduleImages = page.scheduleImages.map { resolve($0) } }
    private func resolveURLs(in page: inout PostArchivePage) { page.items = page.items.map { resolve($0) } }
    private func resolveURLs(in page: inout VideoArchivePage) { page.items = page.items.map { resolve($0) } }
    private func resolveURLs(in uploads: inout WorksUploadsResponse) {
        for key in uploads.uploads.keys {
            guard var item = uploads.uploads[key] else { continue }
            if let cover = item.cover, let url = resolveMediaURL(cover.url.absoluteString) { item.cover = WorksUploadCover(url: url, width: cover.width, height: cover.height) }
            uploads.uploads[key] = item
        }
        uploads.recent = uploads.recent?.map { item in
            var value = item
            value.url = resolveMediaURL(value.url.absoluteString) ?? value.url
            if let cover = value.cover, let url = resolveMediaURL(cover.url.absoluteString) { value.cover = WorksUploadCover(url: url, width: cover.width, height: cover.height) }
            return value
        }
    }
}
