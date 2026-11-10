import SwiftUI

/// A post's ready images: one at its own shape, or up to four in a two-column
/// grid with the number of the rest on the last.
struct PostImageGrid: View {
    let images: [PostImage]
    /// The most images drawn; the last drawn one counts the rest.
    var limit = 4

    var body: some View {
        if images.count == 1, let image = images.first {
            PostImageTile(image: image, aspectRatio: image.aspectRatio ?? 16 / 9, hiddenCount: 0)
        } else if images.isEmpty == false {
            let shown = Array(images.prefix(limit))
            let rows = rows(of: shown)
            Grid(horizontalSpacing: 4, verticalSpacing: 4) {
                ForEach(rows.indices, id: \.self) { index in
                    let row = rows[index]
                    GridRow {
                        ForEach(row) { image in
                            PostImageTile(
                                image: image, aspectRatio: 1,
                                hiddenCount: image.id == shown.last?.id ? images.count - shown.count : 0)
                        }
                        if row.count == 1 {
                            Color.clear
                                .gridCellUnsizedAxes([.horizontal, .vertical])
                        }
                    }
                }
            }
        }
    }

    private func rows(of images: [PostImage]) -> [[PostImage]] {
        stride(from: 0, to: images.count, by: 2).map { Array(images[$0..<min($0 + 2, images.count)]) }
    }
}
