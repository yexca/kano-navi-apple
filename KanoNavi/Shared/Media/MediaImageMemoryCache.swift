import CoreGraphics
import Foundation
import Synchronization

/// Decoded images kept in memory, least recently used out first, within a
/// byte budget. Safe to read from any thread, so a view can check it without
/// waiting for the loader.
nonisolated final class MediaImageMemoryCache: Sendable {
    private struct Entry {
        let image: CGImage
        let originalURL: URL
        let cost: Int
        var lastUse: Int
    }

    private struct State {
        var entries: [String: Entry] = [:]
        var totalCost = 0
        var clock = 0
    }

    /// The most decoded bytes kept.
    let costLimit: Int
    private let state = Mutex(State())

    init(costLimit: Int) {
        self.costLimit = costLimit
    }

    /// The bytes of decoded images held now.
    var totalCost: Int {
        state.withLock { $0.totalCost }
    }

    /// The image decoded for `request`, when it is still held.
    func image(for request: MediaImageRequest) -> CGImage? {
        state.withLock { state in
            let key = request.cacheKey
            guard var entry = state.entries[key] else { return nil }
            state.clock += 1
            entry.lastUse = state.clock
            state.entries[key] = entry
            return entry.image
        }
    }

    /// The largest held image decoded from any copy of the file at
    /// `originalURL`, to show while a larger copy loads.
    func largestImage(of originalURL: URL) -> CGImage? {
        state.withLock { state in
            state.entries.values
                .filter { $0.originalURL == originalURL }
                .max { $0.image.width < $1.image.width }?
                .image
        }
    }

    /// Keeps `image` for `request`, dropping the least recently used images
    /// until the budget holds. An image larger than the whole budget is not
    /// kept.
    func insert(_ image: CGImage, for request: MediaImageRequest) {
        let cost = image.bytesPerRow * image.height
        state.withLock { state in
            let key = request.cacheKey
            if let replaced = state.entries.removeValue(forKey: key) {
                state.totalCost -= replaced.cost
            }
            guard cost <= costLimit else { return }
            state.clock += 1
            state.entries[key] = Entry(
                image: image, originalURL: request.originalURL, cost: cost, lastUse: state.clock)
            state.totalCost += cost
            while state.totalCost > costLimit,
                let oldest = state.entries.min(by: { $0.value.lastUse < $1.value.lastUse })
            {
                state.entries[oldest.key] = nil
                state.totalCost -= oldest.value.cost
            }
        }
    }

    /// Drops every image, for a memory warning.
    func removeAll() {
        state.withLock { state in
            state.entries.removeAll()
            state.totalCost = 0
        }
    }
}
