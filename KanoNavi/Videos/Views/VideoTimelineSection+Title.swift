import Foundation
import SwiftUI

extension VideoTimelineSection {
    /// The section's name, On Air or its month and year, or `nil` for a
    /// section without a month. With `abbreviated`, the month is short, such
    /// as "Nov 2026".
    func title(locale: Locale, abbreviated: Bool = false) -> Text? {
        if isOnAir {
            Text(.Videos.onAir)
        } else if let month {
            Text(verbatim: month.first.monthTitle(locale: locale, abbreviated: abbreviated))
        } else {
            nil
        }
    }
}
