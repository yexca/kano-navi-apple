import KanoNaviCore
import SwiftUI

/// What an On This Day row shows: a small cover, the title and how many
/// years ago the work came out.
struct WorksOnThisDayLabel: View {
    let entry: WorksOnThisDay.Entry

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if dynamicTypeSize.isAccessibilitySize == false {
                cover
                    .frame(width: 56)
            }
            VStack(alignment: .leading, spacing: 2) {
                title
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(.Works.yearsAgo(entry.yearsAgo))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var cover: some View {
        switch entry.work {
        case .release(let release): WorksCoverArt(image: release.covers.first, cornerRadius: 6)
        case .participation(let work): WorksCoverArt(image: work.cover, cornerRadius: 6)
        case .upload(let card): WorksUploadCoverView(cover: card.cover)
        }
    }

    @ViewBuilder
    private var title: some View {
        switch entry.work {
        case .release(let release):
            Text(verbatim: release.title)
                .strikethrough(release.cancelled)
        case .participation(let work): Text(verbatim: work.title)
        case .upload(let card): WorksUploadCardTitle(card: card)
        }
    }
}
