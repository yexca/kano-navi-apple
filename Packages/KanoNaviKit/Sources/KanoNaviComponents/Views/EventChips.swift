import KanoNaviCore
import SwiftUI

/// An entry's labels as a wrapping row of chips: its state, the members
/// chip, the sale mark of this calendar entry, its type and its tag.
///
/// The upcoming state is left out unless `includesUpcomingState` is set,
/// since most entries in a schedule are upcoming. Safe in widgets.
public struct EventChips: View {
    private let event: ScheduleEvent
    private let saleMark: SaleMark?
    private let includesUpcomingState: Bool

    /// Creates the chips for an event, marking `saleMark` when the row
    /// stands for a sale's opening or close.
    public init(event: ScheduleEvent, saleMark: SaleMark? = nil, includesUpcomingState: Bool = false) {
        self.event = event
        self.saleMark = saleMark
        self.includesUpcomingState = includesUpcomingState
    }

    public var body: some View {
        FlowLayout(spacing: 4) {
            if includesUpcomingState || event.displayState != .upcoming {
                EventStateBadge(state: event.displayState)
            }
            if event.isMembersOnly {
                MembersChip()
            }
            if let saleMark {
                SaleChip(mark: saleMark)
            }
            if event.isMembersOnly == false, let typeCode = event.view?.typeCode {
                ComponentChip(
                    title: DisplayCodeLabels.eventType(typeCode), systemImage: nil, tint: .secondary)
            }
            if let activityCode = event.view?.activityCode {
                ComponentChip(title: DisplayCodeLabels.tag(activityCode), systemImage: nil, tint: .secondary)
            }
        }
    }
}
