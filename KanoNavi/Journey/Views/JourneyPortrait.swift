import KanoNaviCore
import SwiftUI

/// An identity's mark cropped to a circle and ringed in its tone: the
/// portrait, or a symbol for the All card and for a branch without one.
struct JourneyPortrait: View {
    let mark: JourneyBranchMark
    let tone: JourneyTone
    /// Whether the circle is ringed in the tone (not for the All card).
    let isRinged: Bool

    var body: some View {
        Circle()
            .fill(.fill.secondary)
            .overlay {
                switch mark {
                case .portrait(let portrait):
                    MediaImage(
                        decorative: portrait.imageSource, contentMode: .fill, anchor: portrait.thumbnailAnchor
                    )
                case .symbol(let systemImage):
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundStyle(isRinged ? AnyShapeStyle(tone.color) : AnyShapeStyle(.secondary))
                }
            }
            .clipShape(.circle)
            .overlay {
                Circle().strokeBorder(tone.color.opacity(isRinged ? 0.6 : 0), lineWidth: 2)
            }
            .accessibilityHidden(true)
    }
}
