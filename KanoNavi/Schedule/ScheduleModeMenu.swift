import SwiftUI

/// The toolbar menu that chooses how the Schedule tab shows its months. Its
/// icon is the current mode's, which carries a checkmark in the menu.
struct ScheduleModeMenu: View {
    @Binding var mode: ScheduleMode

    var body: some View {
        Menu(.Schedule.modeMenu, systemImage: mode.systemImage) {
            Picker(.Schedule.modeMenu, selection: $mode) {
                ForEach(ScheduleMode.allCases) { mode in
                    Label(mode.title, systemImage: mode.systemImage)
                        .tag(mode)
                }
            }
            .pickerStyle(.inline)
        }
    }
}
