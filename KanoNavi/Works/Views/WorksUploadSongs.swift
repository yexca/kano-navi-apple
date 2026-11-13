import SwiftUI

/// The songs of a compilation upload, folded away until asked for.
struct WorksUploadSongs: View {
    let songs: [String]

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(songs.enumerated(), id: \.offset) { index, song in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        WorksTrackNumber(number: index + 1)
                        Text(verbatim: song)
                    }
                }
            }
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
        } label: {
            Text(.Works.songsIn(songs.count))
                .font(.footnote)
        }
    }
}
