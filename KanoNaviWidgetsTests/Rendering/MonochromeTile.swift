import SwiftUI

/// An approximation of the system's monochrome widget rendering (the Lock
/// Screen's vibrant mode and a tinted Home Screen): the dark-appearance
/// tile's luminance becomes the opacity of white over a wallpaper, so color
/// alone no longer tells parts apart. The real modes also tint accented
/// parts, which this leaves white.
struct MonochromeTile<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .environment(\.colorScheme, .dark)
            .luminanceToAlpha()
            .colorInvert()
            .padding(4)
            .background(Color(red: 0.24, green: 0.30, blue: 0.48), in: .rect(cornerRadius: 24))
    }
}
