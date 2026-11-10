import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A video's status in words: the live indicator on air, otherwise a chip.
struct VideoStatusChip: View {
    let status: VideoStatusMark

    var body: some View {
        switch status {
        case .live:
            LiveIndicator()
        case .upcoming:
            ComponentChip(title: DisplayCodeLabels.videoPhase(.upcoming), systemImage: "clock", tint: .blue)
        case .started:
            ComponentChip(
                title: DisplayCodeLabels.videoPhase(.started), systemImage: "play.circle", tint: .orange)
        case .cancelled:
            ComponentChip(
                title: DisplayCodeLabels.videoPhase(.cancelled), systemImage: "xmark.circle", tint: .red)
        }
    }
}
