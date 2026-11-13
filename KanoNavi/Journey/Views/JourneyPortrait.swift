import KanoNaviCore
import SwiftUI

/// An identity's portrait cropped to a circle, ringed in its tone; the All
/// card and a missing portrait draw a symbol instead.
struct JourneyPortrait: View {
    let portrait: JourneyMedia?
    let isAll: Bool
    let tone: JourneyTone

    var body: some View {
        Circle()
            .fill(.fill.secondary)
            .overlay {
                if let portrait {
                    MediaImage(
                        decorative: portrait.imageSource, contentMode: .fill, anchor: portrait.thumbnailAnchor
                    )
                } else {
                    Image(systemName: isAll ? "square.grid.2x2.fill" : "person.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .clipShape(.circle)
            .overlay {
                Circle().strokeBorder(tone.color.opacity(isAll ? 0 : 0.6), lineWidth: 2)
            }
            .accessibilityHidden(true)
    }
}
