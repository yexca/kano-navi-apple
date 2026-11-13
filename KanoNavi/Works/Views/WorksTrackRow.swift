import KanoNaviCore
import SwiftUI

/// One track of a personal release: its number, title, credits and note,
/// and where the same recording can be watched.
struct WorksTrackRow: View {
    let track: WorksTrack

    var body: some View {
        WorksTrackLayout(number: track.no) {
            Text(verbatim: track.title)
        } details: {
            if let credit = track.credit, credit.isEmpty == false {
                WorksText(credit)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let note = track.note, note.isEmpty == false {
                WorksText(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let links = track.listen?.links, links.isEmpty == false {
                WorksWatchLinks(links: links.map { WorksUploadLink($0) }, title: track.title)
                    .padding(.top, 2)
            }
        }
    }
}
