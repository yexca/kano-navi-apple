import KanoNaviCore
import SwiftUI

/// One identity in the filter, as a one-line chip: portrait, name and count,
/// or All when `branch` is `nil`. The selected chip is outlined in its tone
/// and its portrait carries a check mark, so the choice never rests on
/// colour alone.
struct JourneyBranchChip: View {
    let branch: JourneyBranch?
    let count: Int
    /// The worded count VoiceOver reads, such as "12 milestones".
    let countLabel: LocalizedStringResource
    let isSelected: Bool
    let select: () -> Void

    @ContentLocaleSetting private var contentLocale
    @ScaledMetric(relativeTo: .subheadline) private var portraitSize = 28

    var body: some View {
        let tone = JourneyTone(code: branch?.tone ?? "")
        let outline = branch == nil ? Color.accentColor : tone.color
        let size = min(portraitSize, 56)
        Button(action: select) {
            HStack(spacing: 8) {
                JourneyPortrait(mark: JourneyBranchMark(branch: branch), tone: tone, isRinged: branch != nil)
                    .frame(width: size, height: size)
                    .overlay(alignment: .bottomTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, outline)
                                // Sized by the portrait so it never covers it.
                                .font(.system(size: size * 0.45))
                                .background(Circle().fill(.background))
                                .offset(x: size * 0.1, y: size * 0.1)
                                .accessibilityHidden(true)
                        }
                    }
                name
                    .font(.subheadline.weight(.semibold))
                Text(count, format: .number)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            .lineLimit(1)
            .fixedSize()
            .padding(.leading, 6)
            .padding(.trailing, 12)
            .padding(.vertical, 6)
            .frame(maxHeight: .infinity)
            .background(background, in: .capsule)
            .overlay {
                Capsule().strokeBorder(isSelected ? outline : .clear, lineWidth: 2)
            }
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityValue(Text(countLabel))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("journey.branch." + (branch?.id ?? "all"))
    }

    private var name: Text {
        if let branch {
            Text(verbatim: branch.label.resolved(for: contentLocale)?.text ?? "")
        } else {
            Text(.Journey.identityAll)
        }
    }

    private var background: AnyShapeStyle {
        if isSelected, let branch {
            AnyShapeStyle(JourneyTone(code: branch.tone).color.opacity(JourneyTone.tagOpacity))
        } else {
            AnyShapeStyle(.fill.tertiary)
        }
    }
}
