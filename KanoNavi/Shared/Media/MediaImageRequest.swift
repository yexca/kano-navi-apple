import CoreGraphics
import Foundation

/// One load of an image for one place on screen: which copy to fetch and how
/// large to decode it. Two views drawing the same file at the same size make
/// equal requests and share one load and one decoded image.
nonisolated struct MediaImageRequest: Hashable, Sendable {
    /// How the image fills the box it is drawn in.
    enum Mode: Hashable, Sendable {
        /// The whole image is visible inside the box.
        case fit
        /// The image covers the box and is cropped.
        case fill
    }

    /// The original file, shared by every copy of it.
    let originalURL: URL
    /// The file to fetch: the original, or a smaller copy with `w`.
    let url: URL
    /// The box the image is drawn in, in pixels. A height of 0 means the
    /// height is not limited, for an image whose shape is not known yet.
    let pixelWidth: Int
    let pixelHeight: Int
    let mode: Mode

    /// Decoded images are never larger than this on their longer side, so
    /// one very large original cannot take hundreds of megabytes.
    static let maximumPixelDimension = 4096

    /// The request for `source` drawn in a box of `size` points.
    ///
    /// The copy is chosen by `MediaImageVariant` from the width the image is
    /// drawn at, which for a cropped image is wider than the box.
    init(source: MediaImageSource, size: CGSize, displayScale: CGFloat, mode: Mode) {
        let boxWidth = Int((size.width * displayScale).rounded(.up))
        let boxHeight = Int((size.height * displayScale).rounded(.up))
        originalURL = source.url
        pixelWidth = boxWidth
        self.mode = mode
        if let pixelSize = source.pixelSize {
            pixelHeight = boxHeight
            let scale = Self.scale(
                imageWidth: pixelSize.width, imageHeight: pixelSize.height, boxWidth: boxWidth,
                boxHeight: boxHeight, mode: mode)
            let drawnWidth = Int((pixelSize.width * scale).rounded(.up))
            url = MediaImageVariant.url(
                source.url,
                width: MediaImageVariant.width(pixelWidth: drawnWidth, originalWidth: Int(pixelSize.width)))
        } else {
            // A fitted image of unknown shape is laid out by its width; the
            // box's height is a placeholder until the file is read.
            pixelHeight = mode == .fit ? 0 : boxHeight
            url = source.url
        }
    }

    /// Identifies the decoded image in the memory cache and among loads in
    /// flight.
    var cacheKey: String {
        "\(url.absoluteString)|\(pixelWidth)x\(pixelHeight)|\(mode == .fit ? "fit" : "fill")"
    }

    /// The factor that scales an image of the given pixel size to this
    /// request's box. Not limited to 1: a small image reports a factor above
    /// 1, and the decoder never enlarges.
    func scale(imageWidth: CGFloat, imageHeight: CGFloat) -> CGFloat {
        Self.scale(
            imageWidth: imageWidth, imageHeight: imageHeight, boxWidth: pixelWidth, boxHeight: pixelHeight,
            mode: mode)
    }

    /// The longer side, in pixels, to decode an image of the given pixel
    /// size at: enough for the box, never above the file's own size or
    /// `maximumPixelDimension`.
    func decodedMaxPixelSize(imageWidth: Int, imageHeight: Int) -> Int {
        let longer = max(imageWidth, imageHeight)
        let scale = min(1, scale(imageWidth: CGFloat(imageWidth), imageHeight: CGFloat(imageHeight)))
        let scaled = Int((CGFloat(longer) * scale).rounded(.up))
        return max(1, min(scaled, Self.maximumPixelDimension))
    }

    private static func scale(
        imageWidth: CGFloat, imageHeight: CGFloat, boxWidth: Int, boxHeight: Int, mode: Mode
    ) -> CGFloat {
        guard imageWidth > 0, imageHeight > 0 else { return 1 }
        let horizontal = CGFloat(boxWidth) / imageWidth
        guard boxHeight > 0 else { return horizontal }
        let vertical = CGFloat(boxHeight) / imageHeight
        return mode == .fit ? min(horizontal, vertical) : max(horizontal, vertical)
    }
}
