import SwiftUI
import WidgetKit

/// A Home Screen widget frame with the system's content margins, and the
/// widget's background in full color, as the system draws it.
struct HomeTile<Content: View>: View {
    let size: CGSize
    @ViewBuilder let content: Content

    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        content
            .padding(16)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
            .background {
                if renderingMode == .fullColor {
                    WidgetBackground()
                }
            }
            .clipShape(.rect(cornerRadius: 22))
    }
}
