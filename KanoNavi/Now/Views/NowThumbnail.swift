import SwiftUI

/// A 16:9 cover from the API, cropped to fill its box.
struct NowThumbnail: View {
    let url: URL?

    var body: some View {
        Rectangle()
            .fill(.fill.tertiary)
            .aspectRatio(16 / 9, contentMode: .fit)
            .overlay {
                if let url {
                    MediaImage(decorative: MediaImageSource(url: url), contentMode: .fill)
                }
            }
            .clipShape(.rect(cornerRadius: 12))
            .accessibilityHidden(true)
    }
}
