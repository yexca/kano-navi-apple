import SwiftUI

/// The More tab: Settings, About, and the archive screens that come later.
/// See `docs/design.md`.
struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(value: MoreDestination.settings) {
                        Label {
                            Text(.More.moreSettings)
                        } icon: {
                            Image(systemName: "gearshape")
                        }
                    }
                    NavigationLink(value: MoreDestination.about) {
                        Label {
                            Text(.More.moreAbout)
                        } icon: {
                            Image(systemName: "info.circle")
                        }
                    }
                }

                Section {
                    ForEach(MoreUpcomingFeature.allCases) { feature in
                        LabeledContent {
                            Text(.More.moreComingLater)
                        } label: {
                            Label {
                                Text(feature.title)
                            } icon: {
                                Image(systemName: feature.systemImage)
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(.More.moreComingLaterHeader)
                }
            }
            .navigationTitle(.tabMore)
            .navigationDestination(for: MoreDestination.self) { destination in
                switch destination {
                case .settings: SettingsView()
                case .about: AboutView()
                }
            }
        }
    }
}

#Preview {
    MoreView()
}
