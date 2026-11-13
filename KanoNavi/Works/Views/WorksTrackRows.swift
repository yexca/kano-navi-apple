import KanoNaviCore
import SwiftUI

/// The rows of a personal release's or edition's track list: disc headings
/// and tracks.
struct WorksTrackRows: View {
    let tracks: [WorksTrack]

    var body: some View {
        ForEach(WorksTrackList.entries(of: WorksTrackList.discs(of: tracks))) { entry in
            // One container per entry keeps the row's shape the same
            // whichever kind of row it is.
            VStack(alignment: .leading) {
                switch entry.content {
                case .disc(let number, let label):
                    WorksDiscHeading(number: number, label: label)
                case .track(let track):
                    WorksTrackRow(track: track)
                }
            }
        }
    }
}
