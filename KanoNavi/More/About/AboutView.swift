import SwiftUI

/// States that the app is an unofficial fan project, where its data comes
/// from, and links the web board and the source repository.
struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(.appName)
                        .font(.title2.weight(.bold))
                    Text(.More.aboutUnofficial)
                    Text(.More.aboutData)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section {
                if let url = AboutLinks.webBoard {
                    link(.More.aboutWebBoard, systemImage: "safari", url: url)
                }
                if let url = AboutLinks.sourceRepository {
                    link(
                        .More.aboutSourceCode, systemImage: "chevron.left.forwardslash.chevron.right",
                        url: url)
                }
            } header: {
                Text(.More.aboutLinksHeader)
            }

            Section {
                LabeledContent {
                    Text(verbatim: AppVersion.main.displayString)
                } label: {
                    Text(.More.aboutVersion)
                }
            }
        }
        .navigationTitle(.More.moreAbout)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func link(_ title: LocalizedStringResource, systemImage: String, url: URL) -> some View {
        Link(destination: url) {
            LabeledContent {
                Image(systemName: "arrow.up.right")
                    .accessibilityHidden(true)
            } label: {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                        Text(verbatim: url.host() ?? url.absoluteString)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: systemImage)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
