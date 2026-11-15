import SwiftUI

/// The title and symbol of a screen More lists, used by its rows and by
/// the sidebar tabs that show the same screens.
struct MoreItem: Identifiable {
    let destination: MoreDestination
    /// The sidebar tab that shows `destination` at its root.
    let tab: AppTab
    let title: LocalizedStringResource
    let systemImage: String

    var id: MoreDestination { destination }

    static let journey = MoreItem(
        destination: .journey, tab: .journey, title: .More.moreJourney,
        systemImage: "point.bottomleft.forward.to.point.topright.scurvepath")
    static let works = MoreItem(
        destination: .works, tab: .works, title: .More.moreWorks, systemImage: "music.note.list")
    static let lineBlog = MoreItem(
        destination: .lineBlog, tab: .lineBlog, title: .More.moreLineBlog, systemImage: "book.closed")
    static let settings = MoreItem(
        destination: .settings, tab: .settings, title: .More.moreSettings, systemImage: "gearshape")
    static let about = MoreItem(
        destination: .about, tab: .about, title: .More.moreAbout, systemImage: "info.circle")

    /// The archive screens, in display order.
    static let archives = [journey, works, lineBlog]
    /// Settings and About, in display order.
    static let app = [settings, about]
    /// Every screen More lists, in display order.
    static let all = archives + app

    /// The item's label, for a row or a tab.
    var label: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: systemImage)
        }
    }
}
