import KanoNaviCore
import SwiftUI

/// The rows of a participation work's whole track list: disc headings and
/// tracks, with the ones Kano took part in marked.
struct WorksParticipationTrackRows: View {
    let discs: [WorksDiscGroup<WorksParticipationTrack>]

    var body: some View {
        ForEach(WorksTrackList.entries(of: discs)) { entry in
            // One container per entry keeps the row's shape the same
            // whichever kind of row it is.
            VStack(alignment: .leading) {
                switch entry.content {
                case .disc(let number, let label):
                    WorksDiscHeading(number: number, label: label)
                case .track(let track):
                    WorksParticipationTrackRow(track: track, showsDisc: false)
                }
            }
        }
    }
}
