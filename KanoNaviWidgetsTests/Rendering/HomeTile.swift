import SwiftUI

/// A Home Screen widget frame with the system's content margins.
struct HomeTile<Content: View>: View {
    let size: CGSize
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
            .background(.background, in: .rect(cornerRadius: 22))
            .clipShape(.rect(cornerRadius: 22))
    }
}
