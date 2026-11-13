import CoreGraphics
import Testing

@testable import KanoNavi

/// The viewer's zoom, pan and drag-to-close arithmetic.
struct MediaViewerZoomTests {
    /// A wide picture fitted to a portrait page.
    private let content = CGSize(width: 400, height: 300)
    private let container = CGSize(width: 400, height: 800)

    @Test func pinchKeepsThePointUnderTheFingersInPlace() {
        let point = CGPoint(x: 100, y: -50)

        let zoom = MediaViewerZoom().magnified(by: 2, around: point)

        #expect(zoom.scale == 2)
        // The picture point that was under `point` is still there.
        #expect(zoom.offset.width + point.x * 2 == point.x)
        #expect(zoom.offset.height + point.y * 2 == point.y)
    }

    @Test func pinchBelowFittedSettlesBackToFitted() {
        let zoom = MediaViewerZoom().magnified(by: 0.6, around: .zero).settled(
            content: content, container: container)

        #expect(zoom == MediaViewerZoom())
        #expect(zoom.isZoomed == false)
    }

    @Test func pinchBeyondTheLimitSettlesAtTheLimit() {
        let zoom = MediaViewerZoom().magnified(by: 7, around: .zero).settled(
            content: content, container: container)

        #expect(zoom.scale == MediaViewerZoom.maximumScale)
    }

    @Test func panStopsAtThePictureEdges() {
        let zoom = MediaViewerZoom(scale: 2, offset: .zero)
            .moved(by: CGSize(width: 900, height: -900))
            .settled(content: content, container: container)

        // 800 wide on a 400 page: 200 of reach. 600 tall on an 800 page: none.
        #expect(zoom.offset == CGSize(width: 200, height: 0))
    }

    @Test func tallPictureCanBePannedVerticallyOnceItIsTallerThanThePage() {
        let zoom = MediaViewerZoom(scale: 4, offset: .zero)
            .moved(by: CGSize(width: 0, height: -5000))
            .settled(content: content, container: container)

        #expect(zoom.offset.height == -200)
    }

    @Test func doubleTapZoomsInOnThePointAndBackOut() {
        let zoomed = MediaViewerZoom().toggled(
            at: CGPoint(x: 150, y: 0), content: content, container: container)

        #expect(zoomed.scale == MediaViewerZoom.doubleTapScale)
        #expect(zoomed.isZoomed)
        #expect(zoomed.offset.width == -225)
        #expect(zoomed.toggled(at: .zero, content: content, container: container) == MediaViewerZoom())
    }

    @Test func downwardDragClosesPastTheDistance() {
        var drag = MediaViewerDismissDrag()
        drag.update(translation: CGSize(width: 4, height: 20))
        drag.update(translation: CGSize(width: 30, height: 140))

        #expect(drag.isActive)
        #expect(drag.translation == 140)
        #expect(drag.closes(predicted: CGSize(width: 0, height: 150)))
    }

    @Test func shortDragClosesOnlyWhenFlicked() {
        var drag = MediaViewerDismissDrag()
        drag.update(translation: CGSize(width: 0, height: 40))

        #expect(drag.closes(predicted: CGSize(width: 0, height: 60)) == false)
        #expect(drag.closes(predicted: CGSize(width: 0, height: 500)))
    }

    @Test func dragThatStartsSidewaysNeverCloses() {
        var drag = MediaViewerDismissDrag()
        drag.update(translation: CGSize(width: 20, height: 5))
        drag.update(translation: CGSize(width: 30, height: 300))

        #expect(drag.isActive == false)
        #expect(drag.translation == 0)
        #expect(drag.closes(predicted: CGSize(width: 0, height: 900)) == false)
    }

    @Test func upwardDragDoesNotMoveTheViewer() {
        var drag = MediaViewerDismissDrag()
        drag.update(translation: CGSize(width: 0, height: -40))

        #expect(drag.isActive == false)
        #expect(drag.progress == 0)
    }
}
