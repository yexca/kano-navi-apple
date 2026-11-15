import SwiftUI

/// Shows the app icon, name and version, states that the app is an
/// unofficial fan project, links the web board and the source repository,
/// and names the models the app was built with.
struct AboutView: View {
    @ScaledMetric(relativeTo: .title2) private var scaledIconSize: CGFloat = 72

    /// The icon grows with the text size, but only so far, so the name and
    /// version stay near the top at accessibility sizes.
    private var iconSize: CGFloat { min(scaledIconSize, 112) }

    var body: some View {
        Form {
            Section {
                header
            }
            .listRowBackground(Color.clear)

            Section {
                if let url = AboutLinks.webBoard {
                    link(.More.aboutWebBoard, systemImage: "safari", url: url)
                }
                if let url = AboutLinks.sourceRepository {
                    link(
                        .More.aboutSourceCode, systemImage: "chevron.left.forwardslash.chevron.right",
                        url: url)
                }
            } footer: {
                Text(.More.aboutBuiltWithModels(AboutCredits.models.formatted(.list(type: .and))))
            }
        }
        .formStyle(.grouped)
        .readableContentWidth()
        .navigationTitle(.More.moreAbout)
        .inlineNavigationTitle()
    }

    private var header: some View {
        VStack(spacing: 6) {
            Image(.aboutIcon)
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .clipShape(.rect(cornerRadius: iconSize * 0.225))
                .accessibilityHidden(true)
                .padding(.bottom, 6)
            Text(.appName)
                .font(.title2)
                .bold()
            Text(.More.aboutVersionNumber(AppVersion.main.displayString))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
            Text(.More.aboutUnofficial)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
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
