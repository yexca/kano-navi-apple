import CoreGraphics

/// How far a picture in the viewer is magnified and moved.
///
/// `offset` moves the picture's center from the center of the page. Points
/// passed in are measured from the center of the page too.
nonisolated struct MediaViewerZoom: Equatable, Sendable {
    /// 1 is the picture fitted to the page.
    var scale: CGFloat = 1
    var offset = CGSize.zero

    /// The largest scale a pinch settles at.
    static let maximumScale: CGFloat = 5
    /// The scale a double tap zooms to.
    static let doubleTapScale: CGFloat = 2.5

    /// Whether the picture is larger than fitted, so a drag moves it
    /// instead of turning the page or closing the viewer.
    var isZoomed: Bool { scale > 1.01 }

    /// Magnified by `factor`, keeping the point of the picture under
    /// `point` where it is. The scale may pass its limits while fingers are
    /// down; `settled` brings it back.
    func magnified(by factor: CGFloat, around point: CGPoint) -> MediaViewerZoom {
        let newScale = min(max(scale * factor, 0.5), Self.maximumScale * 1.5)
        let ratio = newScale / scale
        return MediaViewerZoom(
            scale: newScale,
            offset: CGSize(
                width: point.x - (point.x - offset.width) * ratio,
                height: point.y - (point.y - offset.height) * ratio))
    }

    /// Moved by `translation`.
    func moved(by translation: CGSize) -> MediaViewerZoom {
        MediaViewerZoom(
            scale: scale,
            offset: CGSize(
                width: offset.width + translation.width, height: offset.height + translation.height)
        )
    }

    /// Where the picture rests once fingers lift: the scale within 1 and
    /// the maximum, and no gap between an edge of the picture and the edge
    /// of the page on a side where the picture is larger than the page.
    /// `content` is the fitted picture's size, `container` the page's.
    func settled(content: CGSize, container: CGSize) -> MediaViewerZoom {
        let newScale = min(max(scale, 1), Self.maximumScale)
        guard newScale > 1 else { return MediaViewerZoom() }
        // Scaling back to the limit keeps the page's center in place.
        let ratio = newScale / scale
        let reach = CGSize(
            width: max(0, (content.width * newScale - container.width) / 2),
            height: max(0, (content.height * newScale - container.height) / 2))
        return MediaViewerZoom(
            scale: newScale,
            offset: CGSize(
                width: min(max(offset.width * ratio, -reach.width), reach.width),
                height: min(max(offset.height * ratio, -reach.height), reach.height)))
    }

    /// A double tap at `point`: zooms in on it, or back out when zoomed.
    func toggled(at point: CGPoint, content: CGSize, container: CGSize) -> MediaViewerZoom {
        guard isZoomed == false else { return MediaViewerZoom() }
        return MediaViewerZoom()
            .magnified(by: Self.doubleTapScale, around: point)
            .settled(content: content, container: container)
    }
}
