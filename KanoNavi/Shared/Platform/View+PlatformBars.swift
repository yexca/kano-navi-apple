import SwiftUI

extension View {
    /// Shows the navigation title in the bar's small inline form on iOS. A
    /// macOS window always shows its title that way.
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
            navigationBarTitleDisplayMode(.inline)
        #else
            self
        #endif
    }

    /// The inset grouped list on iOS, and the inset list, its closest
    /// counterpart, on macOS.
    func insetGroupedListStyle() -> some View {
        #if os(iOS)
            listStyle(.insetGrouped)
        #else
            listStyle(.inset)
        #endif
    }
}
