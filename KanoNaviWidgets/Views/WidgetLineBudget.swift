import SwiftUI

/// How much the list widgets show at a text size. Smaller budgets at larger
/// sizes keep whole rows, and their times, visible instead of clipping them.
/// A line budget counts day headings and entries; at accessibility sizes an
/// entry takes two lines, its time above its title. The large and
/// extra-large week lists show fewer lines when the widget is too short for
/// their budget (`FittingDayList`).
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

    /// Lines in the extra-large widget's day list, beside the card and as
    /// tall as the card and the large widget's list together. At
    /// accessibility sizes the extra-large widget uses the large layout.
    static func extraLarge(_ size: DynamicTypeSize) -> Int {
        switch size {
        case ...DynamicTypeSize.xLarge: 9
        case ...DynamicTypeSize.xxLarge: 7
        case ...DynamicTypeSize.xxxLarge: 5
        default: large(size)
        }
    }
}
