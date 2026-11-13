import KanoNaviCore
import SwiftUI

/// A row of an article's pictures. One picture is drawn whole, no larger
/// than the blog showed it; several share a two-column grid of square
/// thumbnails. A note says how a picture was found when it was added after
/// the recovery archive.
struct LineBlogFigureRow: View {
    let figures: [LineBlogFigure]
    let open: (LineBlogPicture) -> Void

    /// How many thumbnails share a row of the grid.
    private static let columns = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if figures.count == 1, let figure = figures.first {
                LineBlogFigureView(figure: figure, isThumbnail: false, open: open)
            } else {
                Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                    ForEach(Array(stride(from: 0, to: figures.count, by: Self.columns)), id: \.self) {
                        start in
                        GridRow(alignment: .top) {
                            ForEach(0..<Self.columns, id: \.self) { column in
                                if figures.indices.contains(start + column) {
                                    LineBlogFigureView(
                                        figure: figures[start + column], isThumbnail: true, open: open)
                                } else {
                                    // Keeps the last picture of an odd
                                    // number at its column's width.
                                    Color.clear
                                        .gridCellUnsizedAxes(.vertical)
                                }
                            }
                        }
                    }
                }
            }
            ForEach(recoveries, id: \.self) { recovery in
                Text(LineBlogRecoveryNote.text(for: recovery))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// The ways the row's pictures were recovered, each once.
    private var recoveries: [LineBlogImageRecovery] {
        var seen: [LineBlogImageRecovery] = []
        for figure in figures {
            if case .picture(let picture) = figure, let recovery = picture.recovery,
                seen.contains(recovery) == false
            {
                seen.append(recovery)
            }
        }
        return seen
    }
}
