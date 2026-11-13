import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A newer video's title, time and why it is listed.
struct WorksRecentDetails: View {
    let video: WorksRecentUpload

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            NowTitle(text: video.contentTitle, switchable: true)
                .font(.subheadline.weight(.semibold))
            VideoTimeText(time: video.publishedAt)
                .font(.footnote)
            ComponentChip(title: WorksCodeLabels.recentOrigin(video.origin), tint: .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
