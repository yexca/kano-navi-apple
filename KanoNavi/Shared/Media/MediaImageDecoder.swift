import CoreGraphics
import Foundation
import ImageIO

/// Turns downloaded bytes into a bitmap no larger than its place on screen
/// needs.
nonisolated enum MediaImageDecoder {
    /// Decodes `data` scaled down to `request`'s box, upright, with its
    /// pixels ready to draw. Runs on the caller's thread: call it away from
    /// the main actor. Bytes that are not an image are `unavailable`.
    static func image(from data: Data, for request: MediaImageRequest) throws(MediaImageError) -> CGImage {
        // The source keeps no decoded copy of its own; the thumbnail below
        // is the only bitmap made.
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
            let width = properties[kCGImagePropertyPixelWidth] as? Int,
            let height = properties[kCGImagePropertyPixelHeight] as? Int,
            width > 0, height > 0
        else {
            throw .unavailable
        }

        // EXIF orientations 5 to 8 are stored on their side.
        let orientation = properties[kCGImagePropertyOrientation] as? Int ?? 1
        let isSideways = (5...8).contains(orientation)
        let maxPixelSize = request.decodedMaxPixelSize(
            imageWidth: isSideways ? height : width, imageHeight: isSideways ? width : height)

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw .unavailable
        }
        return image
    }
}
