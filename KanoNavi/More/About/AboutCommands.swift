import SwiftUI

/// The app menu's About item, which opens the About window.
struct AboutCommands: Commands {
    /// The About window's scene ID.
    static let windowID = "about"

    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button(.More.aboutWindowTitle) {
                openWindow(id: Self.windowID)
            }
        }
    }
}
