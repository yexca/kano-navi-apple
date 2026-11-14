import KanoNaviCore
import SwiftUI

/// The loaded Journey: the timeline or the gallery, switched in the toolbar,
/// with the identity filter both share, and the milestone pages they push.
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
                JourneyTimelineList(journey: journey, branch: $branch, notice: notice, reload: reload)
            case .gallery:
                JourneyGalleryGrid(
                    journey: journey, branch: $branch, category: $category, notice: notice, reload: reload)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                JourneyModePicker(mode: $mode)
            }
        }
        .navigationDestination(for: JourneyDestination.self) { destination in
            JourneyDestinationView(destination: destination, journey: journey)
        }
    }
}

#Preview {
    NavigationStack {
        JourneyContent(journey: JourneyPreviewData.journey, notice: nil) {}
            .navigationTitle(.More.moreJourney)
            .navigationBarTitleDisplayMode(.inline)
    }
}
