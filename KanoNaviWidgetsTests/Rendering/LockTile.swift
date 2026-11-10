import SwiftUI

/// A Lock Screen widget frame: light content over a dark wallpaper.
struct LockTile<Content: View>: View {
    let size: CGSize
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(width: size.width, height: size.height, alignment: .leading)
            .environment(\.colorScheme, .dark)
            .padding(6)
            .background(Color(red: 0.12, green: 0.14, blue: 0.22), in: .rect(cornerRadius: 10))
    }
}
