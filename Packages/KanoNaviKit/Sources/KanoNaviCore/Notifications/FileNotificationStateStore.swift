import Foundation

/// Stores the notification baseline as a JSON file in Application Support.
public actor FileNotificationStateStore: NotificationStateStore {
    public let fileURL: URL

    public init(fileURL: URL = FileNotificationStateStore.defaultFileURL()) {
        self.fileURL = fileURL
    }

    public static func defaultFileURL(named directoryName: String = "KanoNavi") -> URL {
        let support =
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return
            support
            .appendingPathComponent(directoryName, isDirectory: true)
            .appendingPathComponent("notification-baseline.json", isDirectory: false)
    }

    public func load() async -> NotificationBaseline? {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder.kanoNavi().decode(NotificationBaseline.self, from: data)
        } catch {
            try? FileManager.default.removeItem(at: fileURL)
            return nil
        }
    }

    public func save(_ baseline: NotificationBaseline) async {
        do {
            let directory = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try Self.encoder().encode(baseline)
            try data.write(to: fileURL, options: .atomic)
        } catch {}
    }

    public func clear() async {
        try? FileManager.default.removeItem(at: fileURL)
    }

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
