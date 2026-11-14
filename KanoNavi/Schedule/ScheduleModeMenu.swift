import SwiftUI

/// The toolbar menu that chooses how the Schedule tab shows its months, in
/// Calendar's order: the three grids, a divider, then List. Its icon is the
/// current mode's, which carries a checkmark in the menu.
struct ScheduleModeMenu: View {
    @Binding var mode: ScheduleMode

    var body: some View {
        Menu(.Schedule.modeMenu, systemImage: mode.systemImage) {
            picker(ScheduleMode.gridModes)
            picker([.list])
        }
    }

    /// One section of the menu; the selection is shared, so only the
    /// current mode's section shows a checkmark.
    private func picker(_ modes: [ScheduleMode]) -> some View {
        Picker(.Schedule.modeMenu, selection: $mode) {
            ForEach(modes) { mode in
                Label(mode.title, systemImage: mode.systemImage)
                    .tag(mode)
            }
        }
        .pickerStyle(.inline)
    }
}
