import KanoNaviCore
import SwiftUI

/// Pairs a week row of the List mode's month with the same week drawn as a
/// grid mode's row, so switching modes grows or shrinks the row in place
/// while its days cross-fade. Without a namespace it does nothing.
struct ScheduleWeekMorph: ViewModifier {
    let week: [JapanDate?]
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if let namespace, let first = week.compactMap(\.self).first {
            content.matchedGeometryEffect(id: first, in: namespace)
        } else {
            content
        }
    }
}

extension View {
    /// Morphs this week row with its twin in `namespace`; see
    /// ``ScheduleWeekMorph``.
    func scheduleWeekMorph(_ week: [JapanDate?], in namespace: Namespace.ID?) -> some View {
        modifier(ScheduleWeekMorph(week: week, namespace: namespace))
    }
}
