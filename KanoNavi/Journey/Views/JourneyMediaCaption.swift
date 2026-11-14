import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// What the viewer shows under a Journey image: what it shows, with
/// cancelled-release and third-party marks, its title, its date and what the
/// date is, credit and creator as written, and the source links. Who
/// published the file, the frame time of a video frame and the provenance
/// note open from Details.
struct JourneyMediaCaption: View {
    let media: JourneyMedia

    @ContentLocaleSetting private var contentLocale
    @Environment(\.locale) private var locale
    @State private var showsDetails = false

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
            if let creator = media.creator, creator.isEmpty == false {
                JourneyCaptionFact(label: .Journey.creatorLabel, value: Text(verbatim: creator))
            }
            JourneyCoverCredit(credit: media.cover?.credit)
            if let credit = media.credit, credit.isEmpty == false {
                Text(verbatim: credit)
                    .font(.footnote)
            }
            JourneyMediaLinks(media: media)
                .font(.subheadline)
            Button {
                showsDetails = true
            } label: {
                Label {
                    Text(.Journey.captionDetails)
                } icon: {
                    Image(systemName: "info.circle")
                }
                .font(.footnote)
            }
            // The caption bar measures its content more than once, so the
            // details open over it rather than growing it.
            .popover(isPresented: $showsDetails) {
                ScrollView {
                    details
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(idealWidth: 360, idealHeight: 280)
                .presentationDetents([.medium, .large])
            }
            .accessibilityIdentifier("journey.caption.details")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Who published the file, the frame time and the provenance note.
    private var details: some View {
        VStack(alignment: .leading, spacing: 10) {
            JourneyCaptionFact(
                label: .Journey.sourceKindLabel, value: Text(JourneyLabels.sourceKind(media.sourceKind)))
            if let frameTime = media.frameTime, frameTime.isEmpty == false {
                JourneyCaptionFact(label: .Journey.frameTimeLabel, value: Text(verbatim: frameTime))
            }
            if let note = JourneyLabels.note(media.note) {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var dateText: Text {
        if let date = media.date {
            Text(verbatim: JourneyDateFormat.day(date, locale: locale))
        } else {
            Text(.Journey.dateUnknown)
        }
    }
}
