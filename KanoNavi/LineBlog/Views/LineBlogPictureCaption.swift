import SwiftUI

/// The caption under a picture in the image viewer: what it shows, how it
/// was recovered, where its file came from and the page it linked to.
struct LineBlogPictureCaption: View {
    let picture: LineBlogPicture

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let alt = picture.alt, alt.isEmpty == false {
                Text(verbatim: alt)
                    .font(.headline)
            }
            if let recovery = picture.recovery {
                Text(LineBlogRecoveryNote.text(for: recovery))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let url = picture.sourceURL {
                LineBlogProvenanceLink(title: .LineBlog.recoveredFrom, url: url)
            }
            if let url = picture.link {
                LineBlogProvenanceLink(title: .LineBlog.linkInArticle, url: url)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
