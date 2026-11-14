import KanoNaviCore
import SwiftUI

/// The month grid: Newest at the top, then each year, newest first, as a
/// grid of its twelve months. Months with items show their count and can be
/// chosen; the others are dimmed. Choosing closes the grid.
struct MonthPickerSheet: View {
    let grid: MonthGrid
    @Binding var selection: ArchiveMonthKey?
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
                            MonthGridYearSection(year: year, selection: selection, unit: unit, choose: choose)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showsClose {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close, action: close)
                    }
                }
            }
        }
    }

    private func chooseNewest() {
        selection = nil
        dismiss()
    }

    private func choose(_ month: ArchiveMonthKey) {
        selection = month
        dismiss()
    }

    private func close() {
        dismiss()
    }
}

#Preview {
    @Previewable @State var selection: ArchiveMonthKey?
    let index = ArchiveMonthIndex(
        months: [
            .init(month: "2025-11", total: 3, counts: [:]), .init(month: "2026-02", total: 41, counts: [:]),
            .init(month: "2026-10", total: 12, counts: [:]),
        ], isFromCache: false, fetchedAt: .now)
    Color.clear
        .sheet(isPresented: .constant(true)) {
            MonthPickerSheet(
                grid: MonthGrid(index: index, today: .today), selection: $selection, unit: .posts,
                showsClose: true)
        }
}
