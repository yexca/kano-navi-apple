import KanoNaviCore
import SwiftUI

/// A participation work in the list: a small cover beside its title, date
/// and what Kano did on it. At accessibility text sizes the cover is left
/// out so the title has the row's width.
struct WorksParticipationRow: View {
    let work: WorksParticipation

    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if dynamicTypeSize.isAccessibilitySize == false {
                WorksCoverArt(image: work.cover, cornerRadius: 6)
                    .frame(width: 56)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: work.title)
                    .font(.headline)
                Text(verbatim: WorksDateFormat.date(work.date, locale: locale))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                WorksParticipationMarks(work: work)
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}
