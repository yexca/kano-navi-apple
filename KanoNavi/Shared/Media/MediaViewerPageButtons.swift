#if os(macOS)
    import SwiftUI

    /// The Mac viewer's Previous and Next buttons at the sides of the picture,
    /// for a mouse without a horizontal swipe. A button is dimmed at the end
    /// of the pictures.
    struct MediaViewerPageButtons: View {
        let hasPrevious: Bool
        let hasNext: Bool
        let turn: (Int) -> Void

        var body: some View {
            HStack {
                button(.Media.viewerPrevious, systemImage: "chevron.left", step: -1, isEnabled: hasPrevious)
                Spacer()
                button(.Media.viewerNext, systemImage: "chevron.right", step: 1, isEnabled: hasNext)
            }
            .padding(.horizontal)
        }

        private func button(
            _ title: LocalizedStringResource, systemImage: String, step: Int, isEnabled: Bool
        ) -> some View {
            Button(title, systemImage: systemImage) {
                turn(step)
            }
            .labelStyle(.iconOnly)
            .font(.title3.weight(.semibold))
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .disabled(isEnabled == false)
        }
    }

    #Preview {
        MediaViewerPageButtons(hasPrevious: false, hasNext: true) { _ in }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .environment(\.colorScheme, .dark)
    }
#endif
