import SwiftUI

/// The screen for one `MoreDestination`, shared by the More tab's stack and
/// the sidebar tabs that show More's screens at their roots.
struct MoreDestinationScreen: View {
    let destination: MoreDestination

    var body: some View {
        switch destination {
        case .journey: JourneyView()
        case .works: WorksView()
        case .worksRelease(let releaseID): WorksReleaseScreen(releaseID: releaseID)
        case .lineBlog: LineBlogView()
        case .settings: SettingsView()
        case .notifications: NotificationSettingsView()
        case .about: AboutView()
        }
    }
}
