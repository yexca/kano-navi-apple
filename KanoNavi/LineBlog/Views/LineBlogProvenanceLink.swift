import SwiftUI

/// A link to an address the archive keeps as provenance: where an article,
/// a picture or a video came from. It names the site, and opens outside
/// the app only when the reader taps it.
struct LineBlogProvenanceLink: View {
    let title: LocalizedStringResource
    let url: URL

    var body: some View {
        Link(destination: url) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    if let host = url.host() {
                        Text(verbatim: host)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .multilineTextAlignment(.leading)
            } icon: {
                Image(systemName: "arrow.up.right.square")
            }
            .font(.footnote)
        }
    }
}
