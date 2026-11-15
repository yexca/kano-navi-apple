import SwiftUI

/// One month of the month grid: its short name over its count. The chosen
/// month is filled with the tint; a month that cannot be chosen is dimmed.
/// VoiceOver reads the month and year, then the count.
struct MonthGridCellButton: View {
    let cell: MonthGridCell
    let isSelected: Bool
    let unit: MonthPickerUnit
    /// Set to this month when it is chosen.
    @Binding var choice: MonthPickerChoice?

    @Environment(\.locale) private var locale

    var body: some View {
        Button(action: choose) {
            VStack(spacing: 2) {
                Text(verbatim: cell.month.first.shortMonthTitle(locale: locale))
                    .font(.body.weight(.semibold))
                Text(verbatim: cell.count > 0 ? cell.count.formatted() : " ")
                    .font(.caption)
                    .monospacedDigit()
                    .opacity(isSelected ? 0.9 : 0.7)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundStyle(foreground)
            .background(background, in: .rect(cornerRadius: 12))
            .contentShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(cell.isEnabled == false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: cell.month.title(locale: locale)))
        .accessibilityValue(cell.count > 0 ? Text(unit.count(cell.count)) : Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("month." + cell.month.rawValue)
    }

    private func choose() {
        choice = MonthPickerChoice(month: cell.month)
    }

    private var foreground: AnyShapeStyle {
        if isSelected {
            AnyShapeStyle(.white)
        } else if cell.isEnabled {
            AnyShapeStyle(.primary)
        } else {
            AnyShapeStyle(.tertiary)
        }
    }

    private var background: AnyShapeStyle {
        if isSelected {
            AnyShapeStyle(.tint)
        } else if cell.isEnabled {
            AnyShapeStyle(.fill.tertiary)
        } else {
            AnyShapeStyle(.clear)
        }
    }
}
