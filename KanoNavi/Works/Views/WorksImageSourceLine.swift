import SwiftUI

/// Where a Works image file was taken from: a link to the page, opened in
/// the browser, or the name of the site when the record names no page.
struct WorksImageSourceLine: View {
    let provenance: WorksImageProvenance

    var body: some View {
        ZStack(alignment: .leading) {
            switch provenance {
            case .page(let url, let host):
                Link(destination: url) {
                    Label {
                        Text(.Works.imageSource(host))
                    } icon: {
                        Image(systemName: "arrow.up.right.square")
                    }
                }
            case .site(let name):
                Label {
                    Text(.Works.imageSource(name))
                } icon: {
                    Image(systemName: "link")
                }
                .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
    }
}
