import SwiftUI

extension UnitPoint {
    /// The anchor a CSS `object-position` value names, such as the Journey's
    /// `focus` (`"50% 0%"`): percentages and the keywords `left`, `center`,
    /// `right`, `top` and `bottom`. One value sets the horizontal position
    /// and centers the vertical one. `nil` for anything else, such as
    /// lengths.
    nonisolated init?(objectPosition: String) {
        let parts = objectPosition.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard (1...2).contains(parts.count) else { return nil }

        var x: CGFloat?
        var y: CGFloat?
        for (index, part) in parts.enumerated() {
            switch part.lowercased() {
            case "left": x = 0
            case "right": x = 1
            case "top": y = 0
            case "bottom": y = 1
            case "center":
                if index == 0 { x = x ?? 0.5 } else { y = y ?? 0.5 }
            default:
                guard part.hasSuffix("%"), let percent = Double(part.dropLast()) else { return nil }
                // The first value is horizontal unless a keyword took it.
                if index == 0, x == nil {
                    x = percent / 100
                } else if y == nil {
                    y = percent / 100
                } else {
                    return nil
                }
            }
        }
        self.init(x: x ?? 0.5, y: y ?? 0.5)
    }
}
