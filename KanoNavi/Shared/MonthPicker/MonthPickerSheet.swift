import KanoNaviCore
import SwiftUI

/// The month grid: Newest at the top, then each year, newest first, as a
/// grid of its twelve months. Months with items show their count and can be
/// chosen; the others are dimmed. Choosing closes the grid.
///
/// Its months take the choice through a binding rather than a closure, so a
/// change of the sheet alone, such as its dismissal, leaves them as they are
/// instead of drawing every month again.
struct MonthPickerSheet: View {
    let grid: MonthGrid
    /// The month the timeline starts at, or `nil` for Newest.
    let selection: ArchiveMonthKey?
    /// Set to the month or Newest when one is chosen, which closes the grid.
    @Binding var choice: MonthPickerChoice?
    let unit: MonthPickerUnit
    let showsClose: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        MonthPickerNewestButton(isSelected: selection == nil, action: chooseNewest)

                        ForEach(grid.years) { year in
                            MonthGridYearSection(
                                year: year, selection: selection, unit: unit, choice: $choice)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    if let selection {
                        proxy.scrollTo(selection, anchor: .center)
                    }
                }
            }
            .navigationTitle(.Archive.jumpToMonth)
            .inlineNavigationTitle()
            .toolbar {
                if showsClose {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close, action: close)
                    }
                }
            }
        }
        .onChange(of: choice) {
            if choice != nil {
                dismiss()
            }
        }
    }

    private func chooseNewest() {
        choice = MonthPickerChoice(month: nil)
    }

    private func close() {
        dismiss()
    }
}

#Preview {
    @Previewable @State var choice: MonthPickerChoice?
    let index = ArchiveMonthIndex(
        months: [
            .init(month: "2025-11", total: 3, counts: [:]), .init(month: "2026-02", total: 41, counts: [:]),
            .init(month: "2026-10", total: 12, counts: [:]),
        ], isFromCache: false, fetchedAt: .now)
    Color.clear
        .sheet(isPresented: .constant(true)) {
            MonthPickerSheet(
                grid: MonthGrid(index: index, today: .today), selection: nil, choice: $choice,
                unit: .posts, showsClose: true)
        }
}
