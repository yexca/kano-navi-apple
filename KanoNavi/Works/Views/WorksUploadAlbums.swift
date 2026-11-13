import SwiftUI

/// The albums that include an upload's recording, as the collection names
/// them.
struct WorksUploadAlbums: View {
    let albums: [String]

    @Environment(\.locale) private var locale

    var body: some View {
        Label {
            Text(.Works.onAlbums(albums.formatted(.list(type: .and, width: .narrow).locale(locale))))
        } icon: {
            Image(systemName: "opticaldisc")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}
