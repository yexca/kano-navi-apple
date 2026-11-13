import KanoNaviCore
import SwiftUI

/// The newest releases as a row of covers that scrolls sideways; each opens
/// its release.
struct WorksLatestShelf: View {
    let releases: [WorksRelease]

    @ScaledMetric(relativeTo: .subheadline) private var scaledWidth: CGFloat = 132

    /// Wide enough for a wrapped title at large text sizes, never wider
    /// than leaves the next cover in view.
    private var tileWidth: CGFloat { min(scaledWidth, 220) }

    var body: some View {
        ScrollView(.horizontal) {
            // Not lazy: a lazy row takes its height from the first tiles, and a
            // later tile with a longer title would shrink its cover to fit.
            HStack(alignment: .top, spacing: 12) {
                ForEach(releases) { release in
                    NavigationLink(value: WorksDestination.release(release.id)) {
                        WorksReleaseCard(release: release, showsMarks: false)
                            .frame(width: tileWidth)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("works.release." + release.id)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}
