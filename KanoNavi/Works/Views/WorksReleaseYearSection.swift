import KanoNaviCore
import SwiftUI

/// One year of the shelf: the year over its releases. Covers stand two or
/// more abreast; at accessibility text sizes each release is a row, so its
/// title has the width to wrap.
struct WorksReleaseYearSection: View {
    let group: WorksYearGroup<WorksRelease>

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private static let columns = [GridItem(.adaptive(minimum: 150), spacing: 16, alignment: .top)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            WorksYearHeader(year: group.year, count: group.items.count)
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(group.items) { release in
                        NavigationLink(value: WorksDestination.release(release.id)) {
                            WorksReleaseRow(release: release)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("works.release." + release.id)
                        .accessibilityIdentifier("works.release." + release.id)
                    }
                }
            } else {
                LazyVGrid(columns: Self.columns, alignment: .leading, spacing: 20) {
                    ForEach(group.items) { release in
                        NavigationLink(value: WorksDestination.release(release.id)) {
                            WorksReleaseCard(release: release)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("works.release." + release.id)
                        .accessibilityIdentifier("works.release." + release.id)
                    }
                }
            }
        }
    }
}
