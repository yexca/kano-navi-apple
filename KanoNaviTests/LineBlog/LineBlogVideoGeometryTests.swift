import CoreGraphics
import Testing

@testable import KanoNavi

/// A player is sized from its stream.
struct LineBlogVideoGeometryTests {
    @Test func uprightTrackKeepsItsShape() throws {
        let ratio = try #require(
            LineBlogVideoGeometry.aspectRatio(
                naturalSize: CGSize(width: 1920, height: 1080), transform: .identity))

        #expect(abs(ratio - 16.0 / 9.0) < 0.0001)
    }

    @Test func rotatedTrackIsShownOnItsSide() throws {
        let ratio = try #require(
            LineBlogVideoGeometry.aspectRatio(
                naturalSize: CGSize(width: 1920, height: 1080),
                transform: CGAffineTransform(rotationAngle: .pi / 2)))

        #expect(abs(ratio - 9.0 / 16.0) < 0.0001)
    }

    @Test func emptyTrackHasNoShape() {
        #expect(LineBlogVideoGeometry.aspectRatio(naturalSize: .zero, transform: .identity) == nil)
    }
}
