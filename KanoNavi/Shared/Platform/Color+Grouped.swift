import SwiftUI

#if os(macOS)
    import AppKit
#endif

extension Color {
    /// The background behind grouped content, as an inset grouped list
    /// draws it: the system's grouped background on iOS. A Mac window's
    /// own background is the same as a list's, so there it is a light gray
    /// in light appearance and the window's background in dark.
    static var groupedBackground: Color {
        #if os(iOS)
            Color(.systemGroupedBackground)
        #else
            Color(
                nsColor: NSColor(name: nil) { appearance in
                    appearance.isDark
                        ? .windowBackgroundColor
                        : NSColor(srgbRed: 0.949, green: 0.949, blue: 0.969, alpha: 1)
                })
        #endif
    }

    /// The fill of a group on `groupedBackground`, as a section of an inset
    /// grouped list draws it: white in light appearance, and on a Mac in
    /// dark appearance a gray lifted off the window's background.
    static var groupedCellBackground: Color {
        #if os(iOS)
            Color(.secondarySystemGroupedBackground)
        #else
            Color(
                nsColor: NSColor(name: nil) { appearance in
                    appearance.isDark
                        ? NSColor(srgbRed: 0.173, green: 0.173, blue: 0.180, alpha: 1) : .white
                })
        #endif
    }
}

#if os(macOS)
    extension NSAppearance {
        fileprivate var isDark: Bool {
            bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
        }
    }
#endif
