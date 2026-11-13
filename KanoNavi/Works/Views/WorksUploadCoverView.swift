import KanoNaviCore
import SwiftUI

/// An upload's stored cover in a 16:9 frame with its length in the corner,
/// or a quiet play mark when this upload has none. Decorative.
struct WorksUploadCoverView: View {
    let cover: WorksUploadCover?
    var lengthSeconds: Int?

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
            .overlay(alignment: .bottomTrailing) {
                if let length = WorksDateFormat.length(seconds: lengthSeconds) {
                    Text(verbatim: length)
                        .font(.caption2.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.black.opacity(0.7), in: .rect(cornerRadius: 4))
                        .padding(4)
                }
            }
            .clipShape(.rect(cornerRadius: 8))
            // Keep the height the width gives; a List row placing the row
            // at its measured height must not squeeze the image narrower.
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityHidden(true)
    }
}
