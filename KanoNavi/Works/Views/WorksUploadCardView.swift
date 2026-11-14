import KanoNaviCore
import SwiftUI

/// An upload on the Works entry's shelf: its cover over its title and date.
/// The title takes two lines, or four at accessibility text sizes, where a
/// line holds a word or two; VoiceOver reads all of it.
struct WorksUploadCardView: View {
    let card: WorksUploadCard

    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WorksUploadCoverView(cover: card.cover)
            WorksUploadCardTitle(card: card)
                .font(.subheadline.weight(.semibold))
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 2)
                .multilineTextAlignment(.leading)
            if let date = card.date {
                Text(verbatim: WorksDateFormat.date(date, locale: locale))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}
