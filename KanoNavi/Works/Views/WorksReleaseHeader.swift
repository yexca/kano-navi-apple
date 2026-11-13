import KanoNaviCore
import SwiftUI

/// The top of a release: its first cover large, the other covers beside it
/// as a strip, then title, date and marks.
struct WorksReleaseHeader: View {
    let release: WorksRelease
    let open: (WorksImage) -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            WorksHeroCover(image: release.covers.first, title: release.title, open: open)
            if release.covers.count > 1 {
                WorksImageStrip(images: release.covers, fallbackTitle: release.title, open: open)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: release.title)
                    .font(.title2.bold())
                    .strikethrough(release.cancelled)
                    .accessibilityAddTraits(.isHeader)
                Text(verbatim: WorksDateFormat.date(release.date, locale: locale))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                WorksReleaseMarks(marks: WorksReleaseMark.marks(for: release))
            }
        }
        .padding(.vertical, 4)
    }
}
