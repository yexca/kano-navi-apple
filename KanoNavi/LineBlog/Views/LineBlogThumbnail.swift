import KanoNaviCore
import SwiftUI

/// An article's first picture as a square thumbnail, or a quiet mark for an
/// article without one. Decorative: the row's title says what it is.
struct LineBlogThumbnail: View {
    let media: LineBlogMedia?

    var body: some View {
        if let media, media.isVideo == false {
            MediaImage(
                decorative: MediaImageSource(url: media.url, width: media.width, height: media.height),
                contentMode: .fill
            )
            .clipShape(.rect(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(.fill.tertiary)
                .overlay {
                    Image(systemName: "text.alignleft")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
        }
    }
}
