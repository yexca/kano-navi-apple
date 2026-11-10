import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A video's labels as a wrapping row of chips: its status or form, its tag
/// and who can watch it.
struct VideoChips: View {
    let card: VideoCard
    /// Marks the shelf's lead as the operator's featured video.
    var isFeatured = false

    var body: some View {
        FlowLayout(spacing: 4) {
            if isFeatured {
                ComponentChip(title: .Videos.featured, systemImage: "star.fill", tint: .pink)
            }
            if let status = card.status {
                VideoStatusChip(status: status)
            }
            if let formCode = card.shownFormCode {
                ComponentChip(title: DisplayCodeLabels.form(formCode), tint: .secondary)
            }
            if let tag = card.tag {
                ComponentChip(title: DisplayCodeLabels.tag(tag), tint: .secondary)
            }
            if let availability = card.availability {
                VideoAvailabilityChip(availability: availability)
            }
        }
    }
}
