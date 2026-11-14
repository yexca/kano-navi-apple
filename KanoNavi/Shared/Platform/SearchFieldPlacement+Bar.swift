import SwiftUI

extension SearchFieldPlacement {
    /// A search field that stays in view: under the navigation bar on iOS,
    /// and in the window toolbar on macOS.
    static var alwaysInBar: SearchFieldPlacement {
        #if os(iOS)
            .navigationBarDrawer(displayMode: .always)
        #else
            .toolbar
        #endif
    }
}
