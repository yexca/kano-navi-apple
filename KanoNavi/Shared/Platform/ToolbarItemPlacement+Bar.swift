import SwiftUI

extension ToolbarItemPlacement {
    /// The leading end of the navigation bar on iOS; on macOS the window
    /// toolbar's leading end, beside the title.
    static var barLeading: ToolbarItemPlacement {
        #if os(iOS)
            .topBarLeading
        #else
            .navigation
        #endif
    }

    /// The trailing end of the navigation bar on iOS; on macOS the window
    /// toolbar's trailing end.
    static var barTrailing: ToolbarItemPlacement {
        #if os(iOS)
            .topBarTrailing
        #else
            .primaryAction
        #endif
    }
}
