import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

@testable import KanoNavi

/// Synthetic image files and sources on a reserved domain, for the image
/// loading tests.
nonisolated enum MediaImageFixtures {
    /// A PNG file of one flat color.
    static func png(width: Int, height: Int) -> Data {
        let context = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.setFillColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let data = NSMutableData()
        let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, context.makeImage()!, nil)
        CGImageDestinationFinalize(destination)
        return data as Data
    }

    /// A file address no other test uses, so stubs and counts stay apart
    /// while tests run in parallel.
    static func uniqueURL(_ name: String = "picture.png") -> URL {
        URL(string: "https://example.com/media/journey/\(UUID().uuidString)/\(name)")!
    }

    /// A request for `url` drawn in a box of the given pixels at scale 1.
    static func request(
        _ url: URL, width: CGFloat = 100, height: CGFloat = 100, original: CGSize? = nil,
        mode: MediaImageRequest.Mode = .fit
    ) -> MediaImageRequest {
        MediaImageRequest(
            source: MediaImageSource(url: url, pixelSize: original),
            size: CGSize(width: width, height: height),
            displayScale: 1, mode: mode)
    }
}
