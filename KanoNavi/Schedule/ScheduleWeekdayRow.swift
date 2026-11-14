import SwiftUI

/// The Monday-first row of very short weekday symbols above a month grid.
/// VoiceOver reads each day's full date instead, so the row is hidden from it.
struct ScheduleWeekdayRow: View {
    @Environment(\.locale) private var locale

    var body: some View {
        HStack(spacing: 0) {
            ForEach(symbols.enumerated(), id: \.offset) { _, symbol in
                Text(verbatim: symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }

    /// Very short weekday symbols in the interface language, Monday first.
    private var symbols: [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        return Array(symbols.dropFirst()) + symbols.prefix(1)
    }
}
