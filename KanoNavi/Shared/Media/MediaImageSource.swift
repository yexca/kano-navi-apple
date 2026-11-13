import CoreGraphics
import Foundation

/// One image file on the service's media route: its absolute URL and, when
/// the API states it, the pixel size of the original file.
///
/// Build it from the API record (`url` already resolved against the API base
/// URL, `width` and `height` as the record carries them) and hand it to
/// `MediaImage` or the image viewer. The size lets a view keep its shape
/// while the file loads and lets the loader ask for a smaller copy.
nonisolated struct MediaImageSource: Hashable, Sendable {
    /// The original file, without a `w` parameter.
    let url: URL
    /// The original's size in pixels, or `nil` when the API does not say.
    let pixelSize: CGSize?

    init(url: URL, pixelSize: CGSize? = nil) {
        self.url = url
        if let pixelSize, pixelSize.width > 0, pixelSize.height > 0 {
            self.pixelSize = pixelSize
        } else {
            self.pixelSize = nil
        }
    }

    /// A source from an API record's `width` and `height`; the size is
    /// unknown unless both are present and positive.
    init(url: URL, width: Int?, height: Int?) {
        if let width, let height {
            self.init(url: url, pixelSize: CGSize(width: width, height: height))
        } else {
            self.init(url: url, pixelSize: nil)
        }
    }

    /// Width over height of the original, or `nil` when the size is unknown.
    var aspectRatio: CGFloat? {
        pixelSize.map { $0.width / $0.height }
    }
}
