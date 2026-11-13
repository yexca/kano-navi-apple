import SwiftUI

/// Places one picture of a known shape in the space offered: whole
/// (`fit`) or covering it (`fill`), positioned by `anchor` as CSS
/// `object-position` does, so `anchor` (0.5, 0) keeps the top of a cropped
/// picture in view.
struct MediaImageLayout: Layout {
    /// Width over height of the picture.
    let aspectRatio: CGFloat
    let mode: MediaImageRequest.Mode
    let anchor: UnitPoint

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frame = Self.frame(aspectRatio: aspectRatio, mode: mode, anchor: anchor, in: bounds)
        for subview in subviews {
            subview.place(at: frame.origin, proposal: ProposedViewSize(frame.size))
        }
    }

    /// The picture's frame for `bounds`.
    nonisolated static func frame(
        aspectRatio: CGFloat, mode: MediaImageRequest.Mode, anchor: UnitPoint, in bounds: CGRect
    ) -> CGRect {
        guard aspectRatio > 0, bounds.width > 0, bounds.height > 0 else { return bounds }
        let fitsByWidth = bounds.width / aspectRatio <= bounds.height
        let usesWidth = mode == .fit ? fitsByWidth : fitsByWidth == false
        let size =
            usesWidth
            ? CGSize(width: bounds.width, height: bounds.width / aspectRatio)
            : CGSize(width: bounds.height * aspectRatio, height: bounds.height)
        return CGRect(
            x: bounds.minX + (bounds.width - size.width) * anchor.x,
            y: bounds.minY + (bounds.height - size.height) * anchor.y,
            width: size.width, height: size.height)
    }
}
