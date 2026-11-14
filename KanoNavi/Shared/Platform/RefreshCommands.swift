import SwiftUI

/// View ▸ Refresh (⌘R): reads the screen in front again, as pull to
/// refresh does.
struct RefreshCommands: Commands {
    @FocusedValue(\.screenRefresh) private var refresh

    var body: some Commands {
        CommandGroup(before: .toolbar) {
            Button(.refreshCommand, systemImage: "arrow.clockwise") {
                guard let refresh else { return }
                Task {
                    await refresh()
                }
            }
            .keyboardShortcut("r")
            .disabled(refresh == nil)
            Divider()
        }
    }
}
