import SwiftUI

/// The shelf's filter: the kinds as one row that scrolls sideways, and at
/// its trailing end the platform menu, which stays in place.
struct VideoShelfFilterBar: View {
    /// The kind choices; empty when the shelf has fewer than two kinds.
    let options: [ArchiveFilterOption]
    @Binding var kind: String?
    /// The platforms to choose between; the menu shows with two or more.
    let platforms: [VideoShelfPlatform]
    @Binding var platform: VideoShelfPlatform?

    var body: some View {
        HStack(spacing: 0) {
            if options.isEmpty {
                Spacer()
            } else {
                // Full width up to the menu: the row insets itself.
                ArchiveFilterRow(options: options, selection: $kind, title: .Videos.kindFilter)
            }
            if platforms.count > 1 {
                VideoPlatformMenu(platforms: platforms, selection: $platform)
                    .padding(.trailing)
                    .padding(.vertical, 4)
            }
        }
    }
}
