import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// An upload's words: the song, the original artist and collaborators, its
/// date, kind and marks, and for Chinese readers its title on Bilibili.
struct WorksUploadDetails: View {
    let item: WorksUploadItem

    @Environment(\.locale) private var locale
    @ContentLocaleSetting private var contentLocale

    var body: some View {
        let entry = item.entry
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: entry.song)
                .font(.headline)
            if entry.originalArtist.isEmpty == false {
                Text(.Works.originalBy(entry.originalArtist))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if entry.with.isEmpty == false {
                Text(.Works.withPartners(entry.with))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if contentLocale == .zhHans, entry.bilibiliTitle.isEmpty == false,
                entry.bilibiliTitle != entry.song
            {
                Text(verbatim: entry.bilibiliTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(verbatim: WorksDateFormat.date(entry.date, locale: locale))
                .font(.footnote)
                .monospacedDigit()
                .foregroundStyle(.secondary)
            FlowLayout(spacing: 4) {
                ComponentChip(title: WorksCodeLabels.uploadKind(entry.kind), tint: .secondary)
                if item.hasMembersOnlyVideo {
                    ComponentChip(
                        title: .Works.membersOnly, systemImage: "person.badge.key.fill", tint: .green)
                }
                if item.isGone {
                    ComponentChip(title: .Works.videoGone, systemImage: "eye.slash", tint: .orange)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
