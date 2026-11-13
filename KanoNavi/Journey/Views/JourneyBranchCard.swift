import KanoNaviCore
import SwiftUI

/// One identity in the filter: portrait, name, "since" year and count, or
/// All when `branch` is `nil`. The selected card is outlined in its tone and
/// carries a check mark, so the choice never rests on colour alone.
struct JourneyBranchCard: View {
    let branch: JourneyBranch?
    let count: LocalizedStringResource
    let isSelected: Bool
    let select: () -> Void

    @ContentLocaleSetting private var contentLocale
    /// Grows with the text, but stays narrow enough at the largest sizes
    /// for the next card to show.
    @ScaledMetric(relativeTo: .subheadline) private var cardWidth = 104
    @ScaledMetric(relativeTo: .subheadline) private var portraitSize = 56

    var body: some View {
        let tone = JourneyTone(code: branch?.tone ?? "")
        Button(action: select) {
            VStack(spacing: 6) {
                JourneyPortrait(mark: JourneyBranchMark(branch: branch), tone: tone, isRinged: branch != nil)
                    .frame(width: min(portraitSize, 96), height: min(portraitSize, 96))
                    .overlay(alignment: .bottomTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, branch == nil ? Color.accentColor : tone.color)
                                .font(.title3)
                                .background(Circle().fill(.background))
                        }
                    }
                name
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                if let branch {
                    Text(.Journey.branchSince(branch.since))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(count)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: min(cardWidth, 176))
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(background, in: .rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isSelected ? (branch == nil ? Color.accentColor : tone.color) : .clear, lineWidth: 2)
            }
            .contentShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("journey.branch." + (branch?.id ?? "all"))
    }

    @ViewBuilder
    private var name: some View {
        if let branch {
            Text(verbatim: branch.label.resolved(for: contentLocale)?.text ?? "")
        } else {
            Text(.Journey.identityAll)
        }
    }

    private var background: AnyShapeStyle {
        if isSelected, let branch {
            AnyShapeStyle(JourneyTone(code: branch.tone).color.opacity(0.14))
        } else {
            AnyShapeStyle(.fill.tertiary)
        }
    }
}
