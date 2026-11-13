import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One track of a participation work: its number, title and the artist
/// line as the record writes it. A track Kano took part in carries a mark
/// and her further credits; the others are quieter.
struct WorksParticipationTrackRow: View {
    let track: WorksParticipationTrack
    /// Names the disc above the title, for a list that mixes discs.
    let showsDisc: Bool
    /// Marks a track Kano took part in; off in a list of nothing but her tracks.
    var showsKanoMark = true

    var body: some View {
        WorksTrackLayout(number: track.no) {
            VStack(alignment: .leading, spacing: 2) {
                if showsDisc {
                    Text(.Works.discNumber(track.disc))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text(verbatim: track.title)
                    .fontWeight(track.kano ? .semibold : .regular)
                    .foregroundStyle(track.kano ? .primary : .secondary)
            }
        } details: {
            if track.credit.isEmpty == false {
                Text(verbatim: track.credit)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if track.kano, showsKanoMark || track.kanoCredits.isEmpty == false {
                WorksKanoCreditMarks(credits: track.kanoCredits, showsKanoMark: showsKanoMark)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
