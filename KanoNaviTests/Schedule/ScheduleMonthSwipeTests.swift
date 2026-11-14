import CoreGraphics
import Testing

@testable import KanoNavi

/// A vertical drag on the List mode's month pages as in Calendar: past a
/// third of the month, or flicked, it pages; otherwise it springs back.
struct ScheduleMonthSwipeTests {
    private let height: CGFloat = 300

    @Test(arguments: [
        // Slow drags past a third of the month page; short ones spring back.
        (-110.0, -115.0, 1), (110.0, 112.0, -1), (-60.0, -70.0, 0), (60.0, 70.0, 0),
        // Flicks page from a short distance.
        (-30.0, -260.0, 1), (25.0, 240.0, -1),
        // A drag pulled back against itself before release springs back.
        (-150.0, 40.0, 0), (150.0, -30.0, 0),
    ])
    func dragPagesPastAThirdOrWhenFlicked(_ translation: Double, _ predicted: Double, _ offset: Int) {
        #expect(
            ScheduleMonthSwipe.offset(translation: translation, predicted: predicted, height: height)
                == offset)
    }

    @Test func thresholdFollowsTheMonthsHeight() {
        #expect(ScheduleMonthSwipe.offset(translation: -90, predicted: -90, height: 240) == 1)
        #expect(ScheduleMonthSwipe.offset(translation: -90, predicted: -90, height: 360) == 0)
    }

    @Test func settlesByTheMonthsHeightOrThePreviousMonths() {
        #expect(ScheduleMonthSwipe.settledOffset(direction: 1, height: 300, previousHeight: 250) == -300)
        #expect(ScheduleMonthSwipe.settledOffset(direction: -1, height: 300, previousHeight: 250) == 250)
        #expect(ScheduleMonthSwipe.settledOffset(direction: 0, height: 300, previousHeight: 250) == 0)
    }
}
