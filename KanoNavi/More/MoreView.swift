import SwiftUI

/// The More tab: the Journey, Works and LINE BLOG archive screens, Settings
/// and About. A Journey milestone with a release opens that release's Works
/// screen on the same stack. See `docs/design.md`.
struct MoreView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    row(
                        .journey, title: .More.moreJourney,
                        systemImage: "point.bottomleft.forward.to.point.topright.scurvepath")
                    row(.works, title: .More.moreWorks, systemImage: "music.note.list")
                    row(.lineBlog, title: .More.moreLineBlog, systemImage: "book.closed")
                }

                Section {
                    row(.settings, title: .More.moreSettings, systemImage: "gearshape")
                    row(.about, title: .More.moreAbout, systemImage: "info.circle")
                }
            }
            .navigationTitle(.tabMore)
            .navigationDestination(for: MoreDestination.self) { destination in
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
        .onChange(of: router?.moreDestination, initial: true) { _, destination in
            guard let destination else { return }
            router?.moreDestination = nil
            switch destination {
            case .notifications:
                path = NavigationPath([MoreDestination.settings, MoreDestination.notifications])
            default:
                path = NavigationPath([destination])
            }
        }
        .environment(
            \.journeyOpenRelease,
            JourneyOpenRelease { releaseID in
                path.append(MoreDestination.worksRelease(releaseID))
            })
    }

    private func row(
        _ destination: MoreDestination, title: LocalizedStringResource, systemImage: String
    ) -> some View {
        NavigationLink(value: destination) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
}

#Preview {
    MoreView()
}
