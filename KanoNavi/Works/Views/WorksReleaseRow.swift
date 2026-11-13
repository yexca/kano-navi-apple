import KanoNaviCore
import SwiftUI

/// A release as a row, for accessibility text sizes: a small cover beside
/// its title, date and marks.
struct WorksReleaseRow: View {
    let release: WorksRelease

    @Environment(\.locale) private var locale

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WorksCoverArt(image: release.covers.first, cornerRadius: 8)
                .frame(width: 88)
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: release.title)
                    .font(.headline)
                    .strikethrough(release.cancelled)
                    .multilineTextAlignment(.leading)
                Text(verbatim: WorksDateFormat.date(release.date, locale: locale))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                WorksReleaseMarks(marks: WorksReleaseMark.marks(for: release))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}
