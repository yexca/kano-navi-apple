import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A milestone's date (at its stored precision, with its range and note),
/// branch and kind, wrapping at large text sizes. VoiceOver reads the full
/// date.
struct JourneyMilestoneMeta: View {
    let milestone: JourneyMilestone
    let branch: JourneyBranch?
    let tone: JourneyTone
    /// `true` within a year's section, where the year is the header.
    let isShort: Bool

    @Environment(\.locale) private var locale

    var body: some View {
        let full = JourneyDateFormat.full(milestone.date, end: milestone.dateEnd, locale: locale)
        FlowLayout(spacing: 6) {
            Text(
                verbatim: isShort
                    ? JourneyDateFormat.short(milestone.date, end: milestone.dateEnd, locale: locale) : full
            )
            .font(.footnote.weight(.semibold))
            .foregroundStyle(tone.color)
            .accessibilityLabel(Text(verbatim: full))
            if let note = milestone.dateNote, note.isEmpty == false {
                Text(verbatim: note)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            if let branch {
                JourneyBranchTag(branch: branch, tone: tone)
            }
            Text(JourneyKind(code: milestone.kind).label)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
