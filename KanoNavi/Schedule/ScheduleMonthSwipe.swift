import CoreGraphics

/// How a vertical swipe on the List mode's month pages, as in Calendar:
/// up shows the next month, down the previous one.
nonisolated enum ScheduleMonthSwipe {
    /// How far a drag must go, or be flung, to page.
    static let threshold: CGFloat = 40

    /// The month offset for a drag that moved `translation` points down
    /// (negative for up) and would have ended at `predicted`: 1, -1 or 0.
    static func offset(translation: CGFloat, predicted: CGFloat) -> Int {
        if translation <= -threshold || predicted <= -threshold * 2 {
            return 1
        }
        if translation >= threshold || predicted >= threshold * 2 {
            return -1
        }
        return 0
    }
}
