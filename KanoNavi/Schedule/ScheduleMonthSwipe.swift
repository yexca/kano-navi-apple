import SwiftUI

/// How a vertical drag on the List mode's month pages, as in Calendar: up
/// shows the next month and down the previous one.
nonisolated enum ScheduleMonthSwipe {
    /// The share of the month's height a drag, with its momentum, must reach
    /// to page.
    static let thresholdShare: CGFloat = 1 / 3
    /// The header naming the month a release would show.
    static let headerAnimation = Animation.easeOut(duration: 0.15)

    /// The month during a drag, by how far the finger has moved it on a
    /// month `height` points tall: 1 once it is a third of the way up, -1
    /// a third of the way down, else 0. Unlike a release it ignores speed,
    /// so the header follows where the finger is.
    static func preview(translation: CGFloat, height: CGFloat) -> Int {
        let threshold = max(height, 1) * thresholdShare
        if translation <= -threshold {
            return 1
        }
        if translation >= threshold {
            return -1
        }
        return 0
    }

    /// The spring that carries the months from `start` to `end` after a
    /// release, starting at the finger's `velocity` in points a second.
    static func settleAnimation(from start: CGFloat, to end: CGFloat, velocity: CGFloat) -> Animation {
        .interpolatingSpring(
            duration: 0.35, bounce: 0, initialVelocity: relativeVelocity(velocity, from: start, to: end))
    }

    /// A velocity as a share of the distance left a second, as springs take
    /// it, kept within reason for very short distances.
    static func relativeVelocity(_ velocity: CGFloat, from start: CGFloat, to end: CGFloat) -> Double {
        let distance = end - start
        guard abs(distance) > 1 else { return 0 }
        return Double(min(max(velocity / distance, -30), 30))
    }

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
