import KanoNaviCore
import SwiftUI

/// The newest uploads as a row of covers that scrolls sideways; each opens
/// its watch page.
struct WorksLatestUploadsShelf: View {
    let cards: [WorksUploadCard]

    @ScaledMetric(relativeTo: .subheadline) private var scaledWidth: CGFloat = 176

    /// Wide enough for a two-line title at large text sizes, never wider
    /// than leaves the next cover in view.
    private var tileWidth: CGFloat { min(scaledWidth, 240) }

    var body: some View {
        ScrollView(.horizontal) {
            // Not lazy: a lazy row takes its height from the first tiles, and a
            // later tile with a longer title would shrink its cover to fit.
            HStack(alignment: .top, spacing: 12) {
                ForEach(cards) { card in
                    WorksUploadWatchButton(card: card) {
                        WorksUploadCardView(card: card)
                            .frame(width: tileWidth)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("works.latestUpload." + card.id)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    List {
        Section("Latest Uploads") {
            WorksLatestUploadsShelf(
                cards: WorksUploadCard.newestFirst(
                    list: WorksPreviewData.uploadList, stored: WorksPreviewData.uploads)
            )
            .listRowInsets(EdgeInsets())
        }
    }
    .environment(\.mediaImageLoader, WorksPreviewData.imageLoader)
}
