import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One video newer than the collection: its cover, its title in the
/// content language, when it was published and where to watch it.
struct WorksRecentRow: View {
    let video: WorksRecentUpload

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if dynamicTypeSize.isAccessibilitySize {
                WorksUploadCoverView(cover: video.cover)
                    .frame(maxWidth: 320)
                WorksRecentDetails(video: video)
            } else {
                HStack(alignment: .top, spacing: 12) {
                    WorksUploadCoverView(cover: video.cover)
                        .frame(width: 112)
                    WorksRecentDetails(video: video)
                }
            }
            VideoLinkStrip(links: video.pageLinks)
        }
        .padding(.vertical, 4)
        .fixedSize(horizontal: false, vertical: true)
    }
}
