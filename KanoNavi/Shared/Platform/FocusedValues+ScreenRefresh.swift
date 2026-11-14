import SwiftUI

extension FocusedValues {
    /// Reads the screen in front again, for the View ▸ Refresh command. Set
    /// by `refreshableScreen(action:)`.
    @Entry var screenRefresh: ScreenRefresh?
}
