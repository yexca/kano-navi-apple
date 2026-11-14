import KanoNaviCore
import SwiftUI

/// One milestone in full: date, branch and kind, title and detail in the
/// content language, every image (each opening the viewer, with its
/// provenance link), the source and the further links.
struct JourneyMilestoneDetail: View {
    let milestone: JourneyMilestone
    let branch: JourneyBranch?

    @ContentLocaleSetting private var contentLocale
    @State private var opened: JourneyMedia?

    var body: some View {
        let tone = JourneyTone(code: branch?.tone ?? "")
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    JourneyMilestoneMeta(milestone: milestone, branch: branch, tone: tone, isShort: false)
                    Text(verbatim: milestone.title.resolved(for: contentLocale)?.text ?? "")
                        .font(.title2.bold())
                        .accessibilityAddTraits(.isHeader)
                    if milestone.highlight {
                        JourneyKeyMark(tone: tone)
                    }
                }
                if let detail = milestone.detail?.resolved(for: contentLocale)?.text {
                    Text(verbatim: detail)
                }
                if milestone.media.isEmpty == false {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(.Journey.imagesHeader)
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        ForEach(milestone.media) { media in
                            JourneyDetailImage(media: media) {
                                opened = media
                            }
                        }
                    }
                }
                JourneyMilestoneLinks(milestone: milestone)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .readableContentWidth()
        .navigationTitle(.Journey.detailTitle)
        .navigationBarTitleDisplayMode(.inline)
        .mediaViewer(item: $opened, in: milestone.media, source: \.imageSource) { [contentLocale] media in
            Text(verbatim: media.title(in: contentLocale))
        } caption: { media in
            JourneyMediaCaption(media: media)
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            JourneyMilestoneDetail(
                milestone: JourneyPreviewData.journey.milestones[1],
                branch: JourneyPreviewData.journey.branches[0])
        }
    }
#endif
