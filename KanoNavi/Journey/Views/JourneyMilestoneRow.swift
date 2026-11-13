import KanoNaviCore
import SwiftUI

/// One milestone on the timeline: a marker on the branch's line, the date at
/// its precision, the branch and kind, the title and a short detail in the
/// content language, and its first images. A highlight has a filled marker,
/// a larger title, a tinted card and the words "Key milestone".
struct JourneyMilestoneRow: View {
    let milestone: JourneyMilestone
    let branch: JourneyBranch?

    @ContentLocaleSetting private var contentLocale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var scaledMarker = 30

    var body: some View {
        let tone = JourneyTone(code: branch?.tone ?? "")
        let markerSize = min(scaledMarker, 44)
        HStack(alignment: .top, spacing: 12) {
            JourneyMarker(
                kind: JourneyKind(code: milestone.kind), tone: tone, isHighlight: milestone.highlight
            )
            .frame(width: markerSize, height: markerSize)
            VStack(alignment: .leading, spacing: 6) {
                JourneyMilestoneMeta(milestone: milestone, branch: branch, tone: tone, isShort: true)
                Text(verbatim: milestone.title.resolved(for: contentLocale)?.text ?? "")
                    .font(milestone.highlight ? .title3.bold() : .headline)
                    .accessibilitySortPriority(1)
                if milestone.highlight {
                    JourneyKeyMark(tone: tone)
                }
                if let detail = milestone.detail?.resolved(for: contentLocale)?.text {
                    Text(verbatim: detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 6 : 3)
                }
                if milestone.media.isEmpty == false {
                    JourneyRowThumbnails(media: milestone.media)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.forward")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background {
            if milestone.highlight {
                RoundedRectangle(cornerRadius: 14)
                    .fill(tone.color.opacity(0.08))
            }
        }
        .padding(.horizontal, 4)
        .background(alignment: .leading) {
            Rectangle()
                .fill(tone.color.opacity(0.3))
                .frame(width: 2)
                .padding(.leading, 16 + markerSize / 2 - 1)
                .accessibilityHidden(true)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}
