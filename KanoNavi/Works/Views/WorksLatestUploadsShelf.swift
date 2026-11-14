import KanoNaviCore
import SwiftUI

/// The newest uploads as a grid of covers, two to a row (one at
/// accessibility text sizes); each opens its watch page.
struct WorksLatestUploadsShelf: View {
    let cards: [WorksUploadCard]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var columnCount: Int { dynamicTypeSize.isAccessibilitySize ? 1 : 2 }

    var body: some View {
        // A grid, not a lazy grid: the tiles of a row share its height, so a
        // longer title never shrinks the cover beside it.
        Grid(alignment: .topLeading, horizontalSpacing: 12, verticalSpacing: 16) {
            ForEach(rows, id: \.first?.id) { row in
                GridRow {
                    ForEach(row) { card in
                        WorksUploadWatchButton(card: card) {
                            WorksUploadCardView(card: card)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("works.latestUpload." + card.id)
                    }
                    // An odd last tile keeps its column's width.
                    if row.count < columnCount {
                        Color.clear
                            .gridCellUnsizedAxes(.vertical)
                    }
                }
            }
        }
        .padding()
    }

    /// The cards split into rows of `columnCount`.
    private var rows: [[WorksUploadCard]] {
        stride(from: 0, to: cards.count, by: columnCount).map {
            Array(cards[$0..<min($0 + columnCount, cards.count)])
        }
    }
}

#Preview {
    List {
        Section("Latest Uploads") {
            WorksLatestUploadsShelf(
                cards: Array(
                    WorksUploadCard.newestFirst(
                        list: WorksPreviewData.uploadList, stored: WorksPreviewData.uploads
                    )
                    .prefix(4))
            )
            .listRowInsets(EdgeInsets())
        }
    }
    .environment(\.mediaImageLoader, WorksPreviewData.imageLoader)
}
