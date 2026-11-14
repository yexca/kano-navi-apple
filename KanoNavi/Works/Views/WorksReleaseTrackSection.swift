import KanoNaviCore
import SwiftUI

/// The tracks of a release as a list section, by disc. When the release
/// has editions these are the tracks every edition shares.
struct WorksReleaseTrackSection: View {
    let tracks: [WorksTrack]

    var body: some View {
        Section {
            if tracks.isEmpty {
                Text(.Works.tracksEmpty)
                    .foregroundStyle(.secondary)
            } else {
                WorksTrackRows(tracks: tracks)
            }
        } header: {
            Text(.Works.trackCount(tracks.count))
        }
    }
}
