import SwiftUI

/// How a vertical drag on the List mode's month pages, as in Calendar: up
/// shows the next month and down the previous one.
nonisolated enum ScheduleMonthSwipe {
    /// The share of the month's height a drag, with its momentum, must reach
    /// to page.
    static let thresholdShare: CGFloat = 1 / 3
    /// The month sliding to rest after a release.
    static let settleAnimation = Animation.spring(duration: 0.35, bounce: 0)
    /// The month area fitting the new month's weeks.
    static let resizeAnimation = Animation.snappy(duration: 0.25)

    /// The month offset for a drag that moved `translation` points down
    /// (negative for up) and, with its velocity, would end at `predicted`,
    /// on a month `height` points tall: 1 for the next month, -1 for the
    /// previous one, or 0 to spring back. A slow drag pages once it is past
    /// the threshold; a flick pages from a short distance; a drag pulled back
    /// before release springs back.
    static func offset(translation: CGFloat, predicted: CGFloat, height: CGFloat) -> Int {
        let threshold = max(height, 1) * thresholdShare
        // A release that heads back against the drag springs back.
        if translation != 0, (translation < 0) != (predicted < 0) {
            return 0
        }
        if predicted <= -threshold {
            return 1
        }
        if predicted >= threshold {
            return -1
        }
        return 0
    }

    /// The month's offset while it settles after a release: up by its own
    /// height for the next month, down by the previous month's height for
    /// that one, else back to rest.
    static func settledOffset(direction: Int, height: CGFloat, previousHeight: CGFloat) -> CGFloat {
        switch direction {
        case 1: -height
        case -1: previousHeight
        default: 0
        }
    }
}
