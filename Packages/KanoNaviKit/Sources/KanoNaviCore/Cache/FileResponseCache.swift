import Foundation

/// Stores each response as a JSON file named after its cache key.
///
/// A file that cannot be read back is removed, so a corrupt or outdated entry
/// behaves like a cache miss.
public actor FileResponseCache: ResponseCache {
    public let directory: URL
    public init(directory: URL) { self.directory = directory }

    /// Returns a named directory below the user's caches directory.
    public static func defaultDirectory(named name: String) -> URL {
        let caches =
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return caches.appendingPathComponent(name, isDirectory: true)
    }
    private func fileURL(for key: String) -> URL {
        directory.appendingPathComponent(
            Data(key.utf8).base64EncodedString().replacingOccurrences(of: "/", with: "_") + ".json")
    }
    public func load(key: String) async -> CachedResponse? {
        let url = fileURL(for: key)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder.kanoNavi().decode(CachedResponse.self, from: data)
        } catch {
            try? FileManager.default.removeItem(at: url)
            return nil
        }
    }
    public func save(_ response: CachedResponse, key: String) async {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try Self.encoder().encode(response)
            try data.write(to: fileURL(for: key), options: .atomic)
        } catch {}
    }
    public func remove(key: String) async {
        try? FileManager.default.removeItem(at: fileURL(for: key))
    }

    /// Writes `fetchedAt` as ISO 8601 with milliseconds, which
    /// `JSONDecoder.kanoNavi()` reads back, so the fetch time survives a save.
    private static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        }
        return encoder
    }
}
