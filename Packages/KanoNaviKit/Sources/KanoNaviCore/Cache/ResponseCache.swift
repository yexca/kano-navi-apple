import Foundation

public struct CachedResponse: Codable, Equatable, Sendable {
    public var body: Data
    public var etag: String?
    public var fetchedAt: Date
    public init(body: Data, etag: String?, fetchedAt: Date) { self.body = body; self.etag = etag; self.fetchedAt = fetchedAt }
}

public protocol ResponseCache: Sendable {
    func load(key: String) async -> CachedResponse?
    func save(_ response: CachedResponse, key: String) async
    func remove(key: String) async
}

public actor FileResponseCache: ResponseCache {
    public let directory: URL
    public init(directory: URL) { self.directory = directory }
    private func fileURL(for key: String) -> URL { directory.appendingPathComponent(Data(key.utf8).base64EncodedString().replacingOccurrences(of: "/", with: "_") + ".json") }
    public func load(key: String) async -> CachedResponse? {
        let url = fileURL(for: key)
        do { let data = try Data(contentsOf: url); return try JSONDecoder().decode(CachedResponse.self, from: data) }
        catch { try? FileManager.default.removeItem(at: url); return nil }
    }
    public func save(_ response: CachedResponse, key: String) async {
        do { try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true); let data = try JSONEncoder.kanoNavi().encode(response); try data.write(to: fileURL(for: key), options: .atomic) } catch { }
    }
    public func remove(key: String) async { try? FileManager.default.removeItem(at: fileURL(for: key)) }
}

public actor MemoryResponseCache: ResponseCache {
    private var values: [String: CachedResponse] = [:]
    public init() {}
    public func load(key: String) async -> CachedResponse? { values[key] }
    public func save(_ response: CachedResponse, key: String) async { values[key] = response }
    public func remove(key: String) async { values.removeValue(forKey: key) }
}
