import KanoNaviCore
import SwiftUI

/// Starts a timeline at a month: a calendar button in the navigation bar
/// that opens the month grid, as a sheet on iPhone and a popover on iPad.
/// VoiceOver reads the chosen month, or Newest, as its value.
///
/// A choice is applied only once the grid has closed, so the timeline is
/// rebuilt after the closing animation rather than under it.
struct MonthPickerButton: View {
    let index: ArchiveMonthIndex
    /// The chosen month, or `nil` for the newest item.
    @Binding var selection: ArchiveMonthKey?
    let unit: MonthPickerUnit

    @State private var isPresented = false
    /// The choice made in the open grid, until the grid has closed.
    @State private var choice: MonthPickerChoice?
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Button(action: present) {
            Label {
                Text(.Archive.jumpToMonth)
            } icon: {
                Image(systemName: selection == nil ? "calendar" : "calendar.badge.checkmark")
            }
        }
        .accessibilityValue(Text(verbatim: MonthGrid.title(of: selection, locale: locale)))
        .popover(isPresented: $isPresented) {
            MonthPickerSheet(
                grid: MonthGrid(index: index, today: .today), selection: selection, choice: $choice,
                unit: unit,
                // A popover closes with a tap outside it; a sheet gets a
                // close button.
                showsClose: horizontalSizeClass != .regular
            )
            .frame(idealWidth: 400, idealHeight: 600)
            .presentationDetents([.medium, .large])
            .onDisappear(perform: applyChoice)
        }
    }

    private func present() {
        isPresented = true
    }

    private func applyChoice() {
        guard let choice else { return }
        self.choice = nil
        selection = choice.month
    }
}
