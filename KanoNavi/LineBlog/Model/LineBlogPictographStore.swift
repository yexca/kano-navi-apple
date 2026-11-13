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

    /// Loads the files not held yet. Returns when all have been tried, or
    /// when the calling task is cancelled.
    func load(_ sources: [MediaImageSource], with loader: MediaImageLoader, displayScale: CGFloat) async {
        let missing = sources.filter { images[$0.url] == nil }
        guard missing.isEmpty == false else { return }
        let size = CGSize(width: Self.boxSide, height: Self.boxSide)

        var loaded: [URL: CGImage] = [:]
        var failed: Set<URL> = []
        for source in missing {
            let request = MediaImageRequest(
                source: source, size: size, displayScale: displayScale, mode: .fit)
            if let image = loader.memory.image(for: request) {
                loaded[source.url] = image
            }
        }
        publish(&loaded, &failed)

        let clock = ContinuousClock()
        var lastPublish = clock.now
        await withTaskGroup(of: (URL, CGImage?).self) { group in
            for source in missing where images[source.url] == nil {
                let request = MediaImageRequest(
                    source: source, size: size, displayScale: displayScale, mode: .fit)
                group.addTask {
                    (source.url, try? await loader.image(for: request))
                }
            }
            for await (url, image) in group {
                if let image {
                    loaded[url] = image
                } else if Task.isCancelled == false {
                    failed.insert(url)
                }
                if clock.now - lastPublish >= Self.publishInterval {
                    publish(&loaded, &failed)
                    lastPublish = clock.now
                }
            }
        }
        publish(&loaded, &failed)
    }

    private func publish(_ loaded: inout [URL: CGImage], _ failed: inout Set<URL>) {
        if loaded.isEmpty == false {
            images.merge(loaded) { _, new in new }
            unavailable.subtract(loaded.keys)
            loaded = [:]
        }
        if failed.isEmpty == false {
            unavailable.formUnion(failed)
            failed = []
        }
    }
}
