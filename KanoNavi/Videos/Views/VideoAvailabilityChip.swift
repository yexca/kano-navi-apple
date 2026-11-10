import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// Who can watch a video when not everyone can: the members chip, or a
/// private or removed mark.
struct VideoAvailabilityChip: View {
    let availability: VideoAvailabilityMark

    var body: some View {
        switch availability {
        case .members:
            MembersChip()
        case .private:
            ComponentChip(
                title: DisplayCodeLabels.availability(.private), systemImage: "lock.fill", tint: .secondary)
        case .removed:
            ComponentChip(title: DisplayCodeLabels.availability(.removed), systemImage: "nosign", tint: .red)
        }
    }
}
