import CoreGraphics
import Testing

@testable import KanoNavi

/// A vertical swipe on the List mode's month pages as in Calendar.
struct ScheduleMonthSwipeTests {
    @Test(arguments: [
        (-60.0, -60.0, 1), (-10.0, -200.0, 1), (60.0, 60.0, -1), (10.0, 200.0, -1), (-20.0, -40.0, 0),
        (15.0, 30.0, 0),
    ])
    func swipeUpShowsTheNextMonthAndDownThePrevious(_ translation: Double, _ predicted: Double, _ offset: Int)
    {
        #expect(ScheduleMonthSwipe.offset(translation: translation, predicted: predicted) == offset)
    }
}
