import KanoNaviCore
import SwiftUI

/// A release on the shelf: its cover over its title, date and marks.
struct WorksReleaseCard: View {
    let release: WorksRelease
    var showsMarks = true

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WorksCoverArt(image: release.covers.first)
            Text(verbatim: release.title)
                .font(.subheadline.weight(.semibold))
                .strikethrough(release.cancelled)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            Text(verbatim: WorksDateFormat.date(release.date, locale: locale))
                .font(.footnote)
                .foregroundStyle(.secondary)
            if showsMarks {
                WorksReleaseMarks(marks: WorksReleaseMark.marks(for: release))
            } else if release.cancelled {
                WorksReleaseMarks(marks: [.cancelled])
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}
