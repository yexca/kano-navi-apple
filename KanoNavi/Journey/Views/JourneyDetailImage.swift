import KanoNaviCore
import SwiftUI

/// One image on a milestone's page: the picture at its own shape (tall
/// pictures capped in height), what it is and when, and its source link,
/// which stays when the file is unavailable. Tapping the picture opens the
/// viewer.
struct JourneyDetailImage: View {
    let media: JourneyMedia
    let open: () -> Void

    @ContentLocaleSetting private var contentLocale
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: open) {
                MediaImage(media.imageSource, label: Text(verbatim: media.title(in: contentLocale)))
                    .frame(maxHeight: 440)
                    .clipShape(.rect(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text(.Journey.openImageHint))
            .accessibilityIdentifier("journey.detailImage." + media.id)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: media.title(in: contentLocale))
                    .font(.subheadline.weight(.semibold))
                Text(verbatim: kindAndDate)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)

            if let page = media.sourcePage {
                JourneySourceLink(url: page)
                    .font(.footnote)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// What the image shows, and its date when known: `Artwork · Sep 7, 2016`.
    private var kindAndDate: String {
        var resource = JourneyLabels.category(media.category)
        resource.locale = locale
        let kind = String(localized: resource)
        guard let date = media.date else { return kind }
        return kind + " · " + JourneyDateFormat.day(date, locale: locale)
    }
}
