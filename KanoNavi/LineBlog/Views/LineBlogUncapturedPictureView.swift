import SwiftUI

/// The place of a picture the archive never captured: it says so, says
/// what the picture showed when that is known, and links its original
/// address.
struct LineBlogUncapturedPictureView: View {
    let picture: LineBlogUncapturedPicture

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(.LineBlog.pictureNotArchived)
            } icon: {
                Image(systemName: "photo.badge.exclamationmark")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            if let alt = picture.alt, alt.isEmpty == false {
                Text(verbatim: alt)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let url = picture.remoteURL {
                LineBlogProvenanceLink(title: .LineBlog.originalPictureAddress, url: url)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.quaternary, in: .rect(cornerRadius: 8))
    }
}
