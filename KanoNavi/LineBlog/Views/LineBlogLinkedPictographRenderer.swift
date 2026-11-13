import SwiftUI

/// Draws a paragraph as it is and, over each character that stands for a
/// pictograph inside a link, the pictograph. The character keeps the link,
/// its underline and its place in the line; the picture is centred on it
/// at the character's width.
struct LineBlogLinkedPictographRenderer: TextRenderer {
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            for run in line {
                context.draw(run)
                guard let pictograph = run[LineBlogLinkedPictographAttribute.self] else { continue }
                let image = pictograph.image
                guard image.width > 0, image.height > 0 else { continue }
                let bounds = run.typographicBounds.rect
                let scale = min(bounds.width / CGFloat(image.width), bounds.height / CGFloat(image.height))
                let size = CGSize(width: CGFloat(image.width) * scale, height: CGFloat(image.height) * scale)
                let rect = CGRect(
                    x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2, width: size.width,
                    height: size.height)
                context.draw(Image(decorative: image, scale: 1).interpolation(.high), in: rect)
            }
        }
    }
}
