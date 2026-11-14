import SwiftUI

/// How much the list widgets show at a text size. Smaller budgets at larger
/// sizes keep whole rows, and their times, visible instead of clipping them.
/// A line budget counts day headings and entries; at accessibility sizes an
/// entry takes two lines, its time above its title.
nonisolated enum WidgetLineBudget {
    /// Lines in the medium widget's day list at accessibility sizes.
    static let mediumStacked = 3

    /// Lines an entry takes at a text size.
    static func itemLines(_ size: DynamicTypeSize) -> Int {
        size.isAccessibilitySize ? 2 : 1
    }

    /// Entries the medium widget lists beside its lead entry.
    static func mediumFollowing(_ size: DynamicTypeSize) -> Int {
        size <= .large ? 3 : 2
    }

    /// Lines in the large widget's day list: below the strip and card, or
    /// on their own at accessibility sizes.
    static func large(_ size: DynamicTypeSize) -> Int {
        switch size {
        case ...DynamicTypeSize.xLarge: 5
        case ...DynamicTypeSize.xxLarge: 4
        case ...DynamicTypeSize.xxxLarge: 3
        case ...DynamicTypeSize.accessibility2: 8
        default: 6
        }
    }
}
