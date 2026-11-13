import SwiftUI

/// The timeline marker of a milestone: its kind's symbol in a circle of the
/// branch's tone, filled for a highlight. Decorative; the row says the kind
/// and the highlight in words.
struct JourneyMarker: View {
    let kind: JourneyKind
    let tone: JourneyTone
    let isHighlight: Bool

    var body: some View {
        Circle()
            .fill(isHighlight ? AnyShapeStyle(tone.color) : AnyShapeStyle(.background))
            .overlay {
                Circle()
                    .fill(tone.color.opacity(isHighlight ? 0 : 0.16))
            }
            .overlay {
                Image(systemName: kind.systemImage)
                    .font(.footnote.weight(.semibold))
                    .imageScale(.small)
                    .foregroundStyle(isHighlight ? AnyShapeStyle(.background) : AnyShapeStyle(tone.color))
            }
            .accessibilityHidden(true)
    }
}
