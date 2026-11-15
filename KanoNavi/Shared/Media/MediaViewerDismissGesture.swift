import SwiftUI

/// Pulling the viewer down to close it: the pages follow the finger and the
/// backdrop fades, and on release they close or spring back.
///
/// The drag lives here rather than in ``MediaViewer``, so a frame of the
/// drag redraws only the offset and the backdrop, not the pages and bars.
/// The viewer hears only when a pull starts and ends, through `isActive`.
struct MediaViewerDismissGesture: ViewModifier {
    let isEnabled: Bool
    /// Whether the viewer is being pulled down, for hiding its bars and
    /// holding its pages still.
    @Binding var isActive: Bool
    let close: () -> Void

    @State private var drag = MediaViewerDismissDrag()

    func body(content: Content) -> some View {
        content
            .offset(y: drag.translation)
            .simultaneousGesture(gesture, isEnabled: isEnabled)
            .background {
                Color.black
                    .opacity(1 - 0.6 * drag.progress)
                    .ignoresSafeArea()
            }
    }

    private var gesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                drag.update(translation: value.translation)
                if isActive != drag.isActive {
                    isActive = drag.isActive
                }
            }
            .onEnded { value in
                if drag.closes(predicted: value.predictedEndTranslation) {
                    close()
                } else {
                    withAnimation(.snappy(duration: 0.3)) {
                        drag = MediaViewerDismissDrag()
                        isActive = false
                    }
                }
            }
    }
}
