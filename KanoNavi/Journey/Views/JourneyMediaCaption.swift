import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// What the viewer shows under a Journey image: what it shows, its title,
/// its date and what the date is, who published the file, credit and
/// creator as written, the frame time of a video frame, the provenance note,
/// cancelled-release and third-party marks, and the source links.
struct JourneyMediaCaption: View {
    let media: JourneyMedia

    @ContentLocaleSetting private var contentLocale
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            FlowLayout(spacing: 6) {
                Text(JourneyLabels.category(media.category))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                if media.cancelled == true {
                    ComponentChip(title: .Journey.cancelledMark, systemImage: "xmark.circle", tint: .orange)
                }
                if media.origin == .release, media.isThirdPartyCover {
                    ComponentChip(
                        title: .Journey.thirdPartyMark, systemImage: "shippingbox", tint: .secondary)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: media.title(in: contentLocale))
                    .font(.headline)
                if let caption = media.cover?.caption?.resolved(for: contentLocale)?.text {
                    Text(verbatim: caption)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            JourneyCaptionFact(label: JourneyLabels.dateKind(media.dateKind), value: dateText)
            JourneyCaptionFact(
                label: .Journey.sourceKindLabel, value: Text(JourneyLabels.sourceKind(media.sourceKind)))
            if let creator = media.creator, creator.isEmpty == false {
                JourneyCaptionFact(label: .Journey.creatorLabel, value: Text(verbatim: creator))
            }
            if let frameTime = media.frameTime, frameTime.isEmpty == false {
                JourneyCaptionFact(label: .Journey.frameTimeLabel, value: Text(verbatim: frameTime))
            }
            JourneyCoverCredit(credit: media.cover?.credit)
            if let credit = media.credit, credit.isEmpty == false {
                Text(verbatim: credit)
                    .font(.footnote)
            }
            if let note = JourneyLabels.note(media.note) {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            JourneyMediaLinks(media: media)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dateText: Text {
        if let date = media.date {
            Text(verbatim: JourneyDateFormat.day(date, locale: locale))
        } else {
            Text(.Journey.dateUnknown)
        }
    }
}
