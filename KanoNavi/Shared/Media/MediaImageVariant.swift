import CoreGraphics
import Foundation

/// Which copy of an image to ask the media route for.
///
/// The route serves smaller copies with `?w=` at the listed widths only; any
/// other value answers 404. See the `kano-navi` media cache document,
/// "Resized Copies".
nonisolated enum MediaImageVariant {
    /// The widths the media route accepts, ascending.
    static let widths = [320, 640, 960, 1280, 1920]

    /// The `w` to request for an image drawn `drawnWidth` points wide: the
    /// smallest listed width that covers the pixels drawn and is at or below
    /// the original's width. `nil` means the original, without `w`: when the
    /// original's width is unknown, or no listed width qualifies.
    static func width(drawnWidth: CGFloat, displayScale: CGFloat, originalWidth: Int?) -> Int? {
        width(pixelWidth: Int((drawnWidth * displayScale).rounded(.up)), originalWidth: originalWidth)
    }

    /// The `w` to request for an image drawn `pixelWidth` pixels wide.
    static func width(pixelWidth: Int, originalWidth: Int?) -> Int? {
        guard let originalWidth else { return nil }
        return widths.first { $0 >= pixelWidth && $0 <= originalWidth }
    }

    /// `url` asking for the copy `width` pixels wide, or `url` without a `w`
    /// for the original. Other query items, such as a version, are kept.
    static func url(_ url: URL, width: Int?) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return url }
        var items = (components.queryItems ?? []).filter { $0.name != "w" }
        if let width {
            items.append(URLQueryItem(name: "w", value: String(width)))
        }
        components.queryItems = items.isEmpty ? nil : items
        return components.url ?? url
    }
}
