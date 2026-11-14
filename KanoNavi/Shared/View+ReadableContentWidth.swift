import SwiftUI

extension View {
    /// Centres the content of this `ScrollView` or `List` in a column of
    /// readable width when the container is wider than that; see
    /// `ReadableContentWidth`. Use it on screens of reading content, not on
    /// grids, calendars or the image viewer, which use the whole width.
    func readableContentWidth() -> some View {
        modifier(ReadableContentWidth())
    }
}
