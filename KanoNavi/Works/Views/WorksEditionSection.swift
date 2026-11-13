import KanoNaviCore
import SwiftUI

/// One edition of a release as a list section: what sets it apart, its
/// covers, what is in the package, its store bonuses, its own track list
/// when that differs from the shared one, its discs and its store pages.
struct WorksEditionSection: View {
    let summary: WorksEditionSummary
    /// The release's title, read for an uncaptioned image of an unnamed edition.
    let releaseTitle: String
    let open: (WorksImage) -> Void

    @ContentLocaleSetting private var contentLocale

    var body: some View {
        let edition = summary.edition
        let name = edition.name?.resolved(for: contentLocale)?.text
        Section {
            if edition.cancelled {
                WorksReleaseMarks(marks: [.cancelled])
            }
            ForEach(summary.facts) { fact in
                WorksFactRow(fact: fact)
            }
            if edition.covers.isEmpty == false {
                WorksImageStrip(images: edition.covers, fallbackTitle: name ?? releaseTitle, open: open)
            }
            if edition.bonuses.isEmpty == false || edition.bonusImages.isEmpty == false {
                WorksPackageBonuses(bonuses: edition.bonuses, images: edition.bonusImages, open: open)
            }
            ForEach(edition.storeBonuses.enumerated(), id: \.offset) { _, bonus in
                WorksStoreBonusRow(bonus: bonus, fallbackTitle: name ?? releaseTitle, open: open)
            }
            if let tracks = summary.tracks {
                DisclosureGroup {
                    WorksTrackRows(tracks: tracks)
                } label: {
                    Text(.Works.fullTrackList(tracks.count))
                }
            }
            if summary.discs.isEmpty == false {
                WorksLabeledStrip(
                    title: .Works.discPhotos, images: summary.discs.map(\.image),
                    fallbackTitle: name ?? releaseTitle,
                    open: open)
            }
            WorksStoreRows(listings: edition.stores)
        } header: {
            if let name {
                Text(.Works.editionNamed(name))
            } else {
                Text(.Works.editionNumbered(summary.index + 1))
            }
        }
    }
}
