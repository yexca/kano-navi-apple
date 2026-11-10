import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// An unannounced Bilibili broadcast that is live now.
struct NowLiveBroadcastCard: View {
    let broadcast: NowLiveBroadcast

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NowFlowLayout(spacing: 8) {
                LiveIndicator()
                Text(.Now.spotlightLiveOn(String(localized: DisplayCodeLabels.platform(broadcast.platform))))
                    .font(.subheadline.weight(.semibold))
            }
            Text(verbatim: broadcast.title)
                .font(.headline)
            Text(.Now.startedAt(JSTTimeFormat.dateTime(broadcast.startedAt, locale: locale)))
                .foregroundStyle(.secondary)
            NowLinkButtons(links: [.page(on: broadcast.platform, url: broadcast.url, isLive: true)])
        }
        .padding(.vertical, 4)
    }
}
