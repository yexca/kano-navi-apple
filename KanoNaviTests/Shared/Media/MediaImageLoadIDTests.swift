import Testing

@testable import KanoNavi

/// When a `MediaImage` load starts.
struct MediaImageLoadIDTests {
    @Test func aNewSizeOfAnImageOnScreenWaitsForTheResizeToSettle() {
        #expect(MediaImageLoadID.delay(showingImage: true) == MediaImageLoadID.resizeSettleDelay)
        // Short enough that the sharper copy follows soon after the window stops.
        #expect(MediaImageLoadID.resizeSettleDelay <= .milliseconds(250))
    }

    @Test func aLoadWithNothingOnScreenStartsAtOnce() {
        #expect(MediaImageLoadID.delay(showingImage: false) == nil)
    }
}
