import CoreGraphics
import Foundation
import Observation

/// The pictographs of one article, loaded before the text that holds them
/// is drawn with them.
///
/// Running text is one `Text` per paragraph, and a pictograph inside it is
/// an image run of that text, which needs the decoded image up front. The
/// store loads every pictograph of the article through the shared image
/// loader and publishes them a few at a time, so a paragraph is laid out
/// again once or twice, not once per file.
///
/// A file the server does not have is unavailable at once, and its `alt`
/// is drawn in its place. A fetch that merely failed is tried once more
/// after a moment and only then counted as unavailable; meanwhile its
/// place stays empty. Loading again, as pull to refresh does, tries every
/// file not held yet.
@Observable
final class LineBlogPictographStore {
    /// The decoded pictographs, by file address.
    private(set) var images: [URL: CGImage] = [:]
    /// The files that could not be shown; their `alt` is drawn instead.
    private(set) var unavailable: Set<URL> = []

    /// The box, in points, a pictograph is decoded for: above the largest
    /// text size, so one decoded copy serves every Dynamic Type size.
    private static let boxSide: CGFloat = 64
    /// How long results gather before the text is drawn again.
    private static let publishInterval = Duration.milliseconds(120)

    /// How long after a failed fetch the file is tried once more.
    private let retryDelay: Duration

    init(retryDelay: Duration = .seconds(2)) {
        self.retryDelay = retryDelay
    }

    /// How one file's load ended.
    private enum Outcome: Sendable {
        case loaded(CGImage)
        /// The server does not have the file, or it is not an image.
        case unavailable
        /// The fetch failed; trying again may work.
        case failed
        case cancelled
    }

    /// Loads the files not held yet. Returns when all have been tried, or
    /// when the calling task is cancelled.
    func load(_ sources: [MediaImageSource], with loader: MediaImageLoader, displayScale: CGFloat) async {
        let missing = sources.filter { images[$0.url] == nil }
        guard missing.isEmpty == false else { return }

        let failed = await fetch(missing, with: loader, displayScale: displayScale, isLastTry: false)
        guard failed.isEmpty == false else { return }
        try? await Task.sleep(for: retryDelay)
        guard Task.isCancelled == false else { return }
        _ = await fetch(failed, with: loader, displayScale: displayScale, isLastTry: true)
    }

    /// Fetches `sources` and publishes what arrives. Returns the files
    /// whose fetch failed and is worth another try; on the last try those
    /// become unavailable instead.
    private func fetch(
        _ sources: [MediaImageSource], with loader: MediaImageLoader, displayScale: CGFloat, isLastTry: Bool
    ) async -> [MediaImageSource] {
        let size = CGSize(width: Self.boxSide, height: Self.boxSide)
        var loaded: [URL: CGImage] = [:]
        var missing: Set<URL> = []
        var failed: [MediaImageSource] = []
        var pending: [(MediaImageSource, MediaImageRequest)] = []

        for source in sources {
            let request = MediaImageRequest(
                source: source, size: size, displayScale: displayScale, mode: .fit)
            if let image = loader.memory.image(for: request) {
                loaded[source.url] = image
            } else {
                pending.append((source, request))
            }
        }
        publish(&loaded, &missing)

        let clock = ContinuousClock()
        var lastPublish = clock.now
        await withTaskGroup(of: (MediaImageSource, Outcome).self) { group in
            for (source, request) in pending {
                group.addTask {
                    do {
                        return (source, .loaded(try await loader.image(for: request)))
                    } catch MediaImageError.unavailable {
                        return (source, .unavailable)
                    } catch is MediaImageError {
                        return (source, .failed)
                    } catch {
                        return (source, .cancelled)
                    }
                }
            }
            for await (source, outcome) in group {
                switch outcome {
                case .loaded(let image): loaded[source.url] = image
                case .unavailable: missing.insert(source.url)
                case .failed where isLastTry: missing.insert(source.url)
                case .failed: failed.append(source)
                case .cancelled: break
                }
                if clock.now - lastPublish >= Self.publishInterval {
                    publish(&loaded, &missing)
                    lastPublish = clock.now
                }
            }
        }
        publish(&loaded, &missing)
        return failed
    }

    private func publish(_ loaded: inout [URL: CGImage], _ missing: inout Set<URL>) {
        if loaded.isEmpty == false {
            images.merge(loaded) { _, new in new }
            unavailable.subtract(loaded.keys)
            loaded = [:]
        }
        if missing.isEmpty == false {
            unavailable.formUnion(missing)
            missing = []
        }
    }
}
