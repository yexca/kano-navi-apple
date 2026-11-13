import KanoNaviCore
import SwiftUI

/// An upload's stored cover filling a 16:9 frame, or a quiet play mark when
/// this upload has none. Decorative: the row's words say everything.
struct WorksUploadCoverView: View {
    let cover: WorksUploadCover?

    var body: some View {
        Rectangle()
            .fill(.fill.tertiary)
            .aspectRatio(16 / 9, contentMode: .fit)
            .overlay {
                if let cover {
                    MediaImage(
                        decorative: MediaImageSource(
                            url: cover.url, width: cover.width, height: cover.height),
                        contentMode: .fill)
                } else {
                    Image(systemName: "play.rectangle")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                }
            }
            .clipShape(.rect(cornerRadius: 8))
            // Keep the height the width gives; a List row placing the row
            // at its measured height must not squeeze the image narrower.
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityHidden(true)
    }
}
