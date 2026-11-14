import SwiftUI

/// A video's cover from the API, cropped to fill its box, with its length in
/// the corner when known.
struct VideoThumbnail: View {
    let url: URL?
    /// Width over height: 16:9 for videos, 9:16 for Shorts.
    var aspectRatio: CGFloat = 16 / 9
    var lengthText: String?

    var body: some View {
        Rectangle()
            .fill(.fill.tertiary)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                if let url {
                    MediaImage(decorative: MediaImageSource(url: url), contentMode: .fill)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if let lengthText {
                    Text(verbatim: lengthText)
                        .font(.caption2.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.black.opacity(0.7), in: .rect(cornerRadius: 4))
                        .padding(4)
                }
            }
            .clipShape(.rect(cornerRadius: 10))
            // Keep the height the width gives; a List row placing the row
            // at its measured height must not squeeze the image narrower.
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityHidden(true)
    }
}
