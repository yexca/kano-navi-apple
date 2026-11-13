import CoreGraphics
import Dispatch
import Foundation

/// Loads images from the media route: fetches the file, decodes it to the
/// size it is drawn at away from the main actor, and keeps the result in
/// memory.
///
/// Requests for the same image at the same size share one fetch and one
/// decode. A load stops when every task waiting for it is cancelled, so a
/// cell scrolled away costs nothing more. Views use the loader from the
/// environment (`\.mediaImageLoader`); `MediaImage` is the usual way in.
actor MediaImageLoader {
    /// Fetches the bytes of one file. Throws `MediaImageError`, or
    /// `CancellationError` when cancelled.
    typealias Fetch = @Sendable (URL) async throws -> Data

    private struct Load {
        let id: Int
        let task: Task<CGImage, any Error>
        var waiters: Set<Int>
    }

    /// The app's loader, with the image session and its disk cache.
    static let shared = MediaImageLoader(session: MediaImageDownload.makeSession())

    /// Decoded bytes kept in memory by default: about a hundred thumbnails
    /// and a few full-screen images.
    static let defaultMemoryCostLimit = 128 * 1024 * 1024

    /// Images decoded earlier, readable without waiting for the loader.
    nonisolated let memory: MediaImageMemoryCache

    private let fetch: Fetch
    private var loads: [String: Load] = [:]
    private var lastID = 0
    private let memoryPressure: any DispatchSourceMemoryPressure

    /// A loader that fetches with `session`.
    init(session: URLSession, memoryCostLimit: Int = defaultMemoryCostLimit) {
        let download = MediaImageDownload(session: session)
        self.init(memoryCostLimit: memoryCostLimit) { url in
            try await download.data(from: url)
        }
    }

    /// A loader that fetches with `fetch`, for tests.
    init(memoryCostLimit: Int = defaultMemoryCostLimit, fetch: @escaping Fetch) {
        let memory = MediaImageMemoryCache(costLimit: memoryCostLimit)
        self.memory = memory
        self.fetch = fetch
        memoryPressure = DispatchSource.makeMemoryPressureSource(
            eventMask: [.warning, .critical], queue: .global(qos: .utility))
        memoryPressure.setEventHandler {
            memory.removeAll()
        }
        memoryPressure.resume()
    }

    /// The image for `request`, from memory or loaded now.
    ///
    /// Throws `MediaImageError.unavailable` for a missing or unreadable
    /// file, `.failed` for a failure worth trying again, and
    /// `CancellationError` when the calling task is cancelled.
    func image(for request: MediaImageRequest) async throws -> CGImage {
        if let image = memory.image(for: request) {
            return image
        }
        let key = request.cacheKey
        lastID += 1
        let waiter = lastID
        let load = join(key, request: request, waiter: waiter)

        let result = await withTaskCancellationHandler {
            await load.task.result
        } onCancel: {
            Task { await self.cancel(waiter: waiter, key: key, loadID: load.id) }
        }

        leave(waiter: waiter, key: key, loadID: load.id)
        try Task.checkCancellation()
        return try result.get()
    }

    /// How many tasks wait for `request` now, for tests.
    func waiterCount(for request: MediaImageRequest) -> Int {
        loads[request.cacheKey]?.waiters.count ?? 0
    }

    private func join(_ key: String, request: MediaImageRequest, waiter: Int) -> Load {
        if var load = loads[key] {
            load.waiters.insert(waiter)
            loads[key] = load
            return load
        }
        lastID += 1
        let task = Task { [fetch, memory] in
            let data = try await fetch(request.url)
            try Task.checkCancellation()
            let image = try await Self.decode(data, for: request)
            memory.insert(image, for: request)
            return image
        }
        let load = Load(id: lastID, task: task, waiters: [waiter])
        loads[key] = load
        return load
    }

    /// A waiter got its result: the load is over once nobody waits for it.
    private func leave(waiter: Int, key: String, loadID: Int) {
        guard var load = loads[key], load.id == loadID else { return }
        load.waiters.remove(waiter)
        loads[key] = load.waiters.isEmpty ? nil : load
    }

    /// A waiter was cancelled: the load stops when it was the last one, and
    /// carries on for the others otherwise.
    private func cancel(waiter: Int, key: String, loadID: Int) {
        guard var load = loads[key], load.id == loadID else { return }
        load.waiters.remove(waiter)
        if load.waiters.isEmpty {
            load.task.cancel()
            loads[key] = nil
        } else {
            loads[key] = load
        }
    }

    /// Decodes on the global executor, so several images decode at once and
    /// none of them on the loader or the main actor.
    @concurrent
    private static func decode(_ data: Data, for request: MediaImageRequest) async throws -> CGImage {
        try MediaImageDecoder.image(from: data, for: request)
    }
}
