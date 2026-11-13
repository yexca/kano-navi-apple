import SwiftUI

/// One picture of the viewer, fitted to the page: pinch or double tap to
/// zoom, drag to move it while zoomed, tap to show or hide the viewer's
/// bars.
struct MediaViewerPage: View {
    let source: MediaImageSource
    let label: Text
    /// Set while the picture is zoomed or being pinched, so the viewer
    /// stops turning pages and closing on a drag.
    @Binding var isZoomed: Bool
    let tap: () -> Void

    @State private var zoom = MediaViewerZoom()
    @State private var pinchStart: MediaViewerZoom?
    @State private var panStart: MediaViewerZoom?
    @State private var contentSize = CGSize.zero
    @State private var containerSize = CGSize.zero

    var body: some View {
        MediaImage(source, label: label)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                contentSize = size
            }
            .scaleEffect(zoom.scale)
            .offset(zoom.offset)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                containerSize = size
            }
            .onTapGesture(count: 2, coordinateSpace: .local, perform: doubleTap)
            .onTapGesture(perform: tap)
            .gesture(pinch)
            .simultaneousGesture(pan, isEnabled: zoom.isZoomed)
            .onChange(of: zoom.isZoomed || pinchStart != nil) { _, zoomed in
                isZoomed = zoomed
            }
            .accessibilityElement(children: .combine)
            .accessibilityZoomAction(zoomForAccessibility)
    }

    private var pinch: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let start = pinchStart ?? zoom
                pinchStart = start
                zoom = start.magnified(by: value.magnification, around: fromCenter(value.startLocation))
            }
            .onEnded { _ in
                pinchStart = nil
                settle(zoom)
            }
    }

    private var pan: some Gesture {
        DragGesture()
            .onChanged { value in
                guard pinchStart == nil else { return }
                let start = panStart ?? zoom
                panStart = start
                zoom = start.moved(by: value.translation)
            }
            .onEnded { value in
                guard let start = panStart else { return }
                panStart = nil
                // Carry on where the finger was heading.
                settle(start.moved(by: value.predictedEndTranslation))
            }
    }

    private func doubleTap(at location: CGPoint) {
        withAnimation(.snappy(duration: 0.3)) {
            zoom = zoom.toggled(at: fromCenter(location), content: contentSize, container: containerSize)
        }
    }

    private func zoomForAccessibility(_ action: AccessibilityZoomGestureAction) {
        let factor: CGFloat = action.direction == .zoomIn ? 1.5 : 1 / 1.5
        settle(zoom.magnified(by: factor, around: .zero))
    }

    private func settle(_ target: MediaViewerZoom) {
        withAnimation(.snappy(duration: 0.3)) {
            zoom = target.settled(content: contentSize, container: containerSize)
        }
    }

    /// A point of the page measured from the page's center.
    private func fromCenter(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x - containerSize.width / 2, y: point.y - containerSize.height / 2)
    }
}
