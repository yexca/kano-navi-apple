import SwiftUI

/// How the Schedule tab moves from one mode to another, after Calendar.
nonisolated enum ScheduleModeSwitch: Equatable {
    /// No motion: a deep link, the same mode, or a switch made while another
    /// is still running.
    case instant
    /// A cross-fade, for Reduce Motion.
    case crossFade
    /// From List to a grid mode: the month's weeks grow in place into the
    /// grid's, the next months fade in below and the day's entries slide
    /// away, then the grid, laid out the same, takes over.
    case expand(to: ScheduleMode)
    /// From a grid mode to List: the grid brings the month to the top, List
    /// takes over drawn the same, then the weeks shrink into List's, the
    /// next months fade out and the day's entries slide up.
    case collapse(from: ScheduleMode)
    /// Between grid modes: the grid brings the month to the top, then the
    /// cells change height and content in place.
    case restyle

    static func between(
        _ old: ScheduleMode, _ new: ScheduleMode, reducesMotion: Bool, isInstant: Bool
    ) -> Self {
        if isInstant || old == new {
            return .instant
        }
        if reducesMotion {
            return .crossFade
        }
        switch (old, new) {
        case (.list, _): return .expand(to: new)
        case (_, .list): return .collapse(from: old)
        default: return .restyle
        }
    }

    /// The weeks growing or shrinking, and the grid cells changing height.
    static let morphAnimation = Animation.spring(duration: 0.4, bounce: 0)
    /// The grid bringing the month to the top before List takes over.
    static let alignAnimation = Animation.snappy(duration: 0.18)
    /// When List takes over at the latest; a scroll's completion can come
    /// late.
    static let alignDuration = Duration.milliseconds(180)
    /// The Reduce Motion switch.
    static let crossFadeAnimation = Animation.easeInOut(duration: 0.25)
}
