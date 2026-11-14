import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A video's labels as a wrapping row of chips: its status or form, its tag
/// and who can watch it.
struct VideoChips: View {
    let card: VideoCard

    var body: some View {
        FlowLayout(spacing: 4) {
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
