import SwiftUI

/// How many lines of text (day headings and entries) fit in the list
/// widgets at a text size. Smaller budgets at larger sizes keep whole rows,
/// and their times, visible instead of clipping them. At accessibility
/// sizes an entry takes two lines, its time above its title.
nonisolated enum WidgetLineBudget {
    /// Lines an entry takes at a text size.
    static func itemLines(_ size: DynamicTypeSize) -> Int {
        size.isAccessibilitySize ? 2 : 1
    }

    static func medium(_ size: DynamicTypeSize) -> Int {
        switch size {
        case ...DynamicTypeSize.large: 5
        case ...DynamicTypeSize.xxxLarge: 4
        default: 3
        }
    }

    static func large(_ size: DynamicTypeSize) -> Int {
        switch size {
        case ...DynamicTypeSize.large: 12
        case ...DynamicTypeSize.xxLarge: 10
        case ...DynamicTypeSize.xxxLarge: 9
        case ...DynamicTypeSize.accessibility2: 8
        default: 6
        }
    }
}
