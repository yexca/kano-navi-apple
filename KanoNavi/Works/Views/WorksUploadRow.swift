import KanoNaviCore
import SwiftUI

/// One upload: its cover when the list has covers, the song and who it is
/// by and with, its date and kind, the albums that include the recording,
/// a compilation's songs, and where to watch it. At accessibility text
/// sizes the cover sits above the text.
struct WorksUploadRow: View {
    let item: WorksUploadItem
    /// Whether the list keeps room for covers; see `WorksUploadCatalog.showsCovers(kind:)`.
    let showsCover: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsCover, dynamicTypeSize.isAccessibilitySize {
                WorksUploadCoverView(cover: item.cover)
                    .frame(maxWidth: 320)
                WorksUploadDetails(item: item)
            } else {
                HStack(alignment: .top, spacing: 12) {
                    if showsCover {
                        WorksUploadCoverView(cover: item.cover)
                            .frame(width: 112)
                    }
                    WorksUploadDetails(item: item)
                }
            }
            if item.entry.albums.isEmpty == false {
                WorksUploadAlbums(albums: item.entry.albums)
            }
            if item.entry.tracks.isEmpty == false {
                WorksUploadSongs(songs: item.entry.tracks)
            }
            WorksWatchLinks(links: item.links, title: item.entry.song)
        }
        .padding(.vertical, 4)
        // Take the height the content needs; a List row placed at a smaller
        // height would squeeze wrapped text to one truncated line.
        .fixedSize(horizontal: false, vertical: true)
    }
}
