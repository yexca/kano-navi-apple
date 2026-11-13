import SwiftUI
import Testing

@testable import KanoNavi

/// Where a picture sits in its box, and the anchors the API's focus names.
struct MediaImageLayoutTests {
    private let box = CGRect(x: 0, y: 0, width: 100, height: 100)

    @Test func croppedPictureKeepsItsAnchorInView() {
        // A tall picture anchored at its top: the bottom half is cropped.
        let top = MediaImageLayout.frame(
            aspectRatio: 0.5, mode: .fill, anchor: UnitPoint(x: 0.5, y: 0), in: box)
        let center = MediaImageLayout.frame(aspectRatio: 0.5, mode: .fill, anchor: .center, in: box)
        let trailing = MediaImageLayout.frame(aspectRatio: 2, mode: .fill, anchor: .trailing, in: box)

        #expect(top == CGRect(x: 0, y: 0, width: 100, height: 200))
        #expect(center == CGRect(x: 0, y: -50, width: 100, height: 200))
        #expect(trailing == CGRect(x: -100, y: 0, width: 200, height: 100))
    }

    @Test func fittedPictureIsWholeAndCentered() {
        let tall = MediaImageLayout.frame(aspectRatio: 0.5, mode: .fit, anchor: .center, in: box)
        let wide = MediaImageLayout.frame(aspectRatio: 2, mode: .fit, anchor: .center, in: box)

        #expect(tall == CGRect(x: 25, y: 0, width: 50, height: 100))
        #expect(wide == CGRect(x: 0, y: 25, width: 100, height: 50))
    }

    @Test(arguments: [
        ("50% 0%", 0.5, 0.0), ("0% 100%", 0.0, 1.0), ("30% 62.5%", 0.3, 0.625), ("center top", 0.5, 0.0),
        ("left", 0.0, 0.5), ("right bottom", 1.0, 1.0), ("top", 0.5, 0.0), ("25%", 0.25, 0.5),
        ("center", 0.5, 0.5), ("  50%   10% ", 0.5, 0.1),
    ])
    func readsAnObjectPosition(value: String, x: Double, y: Double) throws {
        let point = try #require(UnitPoint(objectPosition: value))

        #expect(abs(point.x - x) < 0.0001)
        #expect(abs(point.y - y) < 0.0001)
    }

    @Test(arguments: ["", "10px 20px", "50% 0% 10%", "middle", "50"])
    func rejectsWhatItCannotRead(value: String) {
        #expect(UnitPoint(objectPosition: value) == nil)
    }
}
