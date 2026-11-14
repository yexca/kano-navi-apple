import SwiftUI

/// States that the app is an unofficial fan project, links the web board and
/// the source repository, and lists the models the app was built with.
struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(.appName)
                        .font(.title2.weight(.bold))
                    Text(.More.aboutUnofficial)
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
            }

            Section {
                ForEach(AboutCredits.models, id: \.self) { model in
                    Text(verbatim: model)
                }
            } header: {
                Text(.More.aboutBuiltWith)
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
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            } label: {
                Label {
                    Text(title)
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
