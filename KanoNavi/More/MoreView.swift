import SwiftUI

/// The More tab: the Journey, Works and LINE BLOG archive screens, Settings
/// and About. See `docs/design.md`.
struct MoreView: View {
    var body: some View {
        NavigationStack {
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
                case .lineBlog: LineBlogView()
                case .settings: SettingsView()
                case .about: AboutView()
                }
            }
        }
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
