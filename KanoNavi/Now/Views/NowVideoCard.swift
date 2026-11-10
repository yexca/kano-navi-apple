import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The latest video.
struct NowVideoCard: View {
    let video: NowVideo

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NowThumbnail(url: video.thumbnailURL)
            if let formCode = video.formCode {
                NowChip(label: DisplayCodeLabels.form(formCode))
            }
            NowTitle(text: video.title, switchable: true)
                .font(.headline)
            if let publishedAt = video.publishedAt {
                Text(verbatim: JSTTimeFormat.dateTime(publishedAt, locale: locale))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            NowLinkButtons(links: [.page(on: video.platform, url: video.url)])
        }
        .padding(.vertical, 8)
    }
}
