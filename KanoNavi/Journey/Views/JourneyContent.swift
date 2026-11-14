import KanoNaviCore
import SwiftUI

/// The loaded Journey: the timeline or the gallery, switched in the toolbar,
/// under the identity filter both share, pinned in the bar area so it stays
/// while either scrolls, and the milestone pages they push.
struct JourneyContent: View {
    let journey: JourneyResponse
    let notice: DocumentNotice?
    let reload: () async -> Void

    @State private var mode = JourneyMode.timeline
    /// The branch ID the timeline and the gallery show, or `nil` for all.
    @State private var branch: String?
    /// The gallery's category code, or `nil` for every image.
    @State private var category: String?

    var body: some View {
        VStack(spacing: 0) {
            switch mode {
            case .timeline:
                JourneyTimelineList(journey: journey, branch: branch, notice: notice, reload: reload)
            case .gallery:
                JourneyGalleryGrid(
                    journey: journey, branch: branch, category: $category, notice: notice, reload: reload)
            }
        }
        .safeAreaBar(edge: .top) {
            filter
        }
        // A firm edge under the chips, so rows and year headers never show
        // through them.
        .scrollEdgeEffectStyle(.hard, for: .top)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                JourneyModePicker(mode: $mode)
            }
        }
        .navigationDestination(for: JourneyDestination.self) { destination in
            JourneyDestinationView(destination: destination, journey: journey)
        }
    }

    /// The identity chips, counting milestones on the timeline and images in
    /// the gallery. One filter for both, so switching keeps where it scrolled.
    private var filter: JourneyBranchFilter {
        let counts: [String: Int]
        let total: Int
        let countLabel: (Int) -> LocalizedStringResource
        switch mode {
        case .timeline:
            counts = JourneyTimeline.milestoneCounts(journey.milestones)
            total = journey.milestones.count
            countLabel = { .Journey.milestoneCount($0) }
        case .gallery:
            let gallery = JourneyGallery(journey)
            counts = gallery.branchCounts
            total = gallery.items.count
            countLabel = { .Journey.imageCount($0) }
        }
        return JourneyBranchFilter(
            branches: journey.branches, selection: $branch, counts: counts, total: total,
            countLabel: countLabel)
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            JourneyContent(journey: JourneyPreviewData.journey, notice: nil) {}
                .navigationTitle(.More.moreJourney)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
#endif
