import KanoNaviCore
import SwiftUI

/// The words that qualify an entry: a sale's opening or closing, members
/// only, and a cancelled or suspected cancellation state.
struct EntryMarks: View {
    let item: WidgetItem

    var body: some View {
        HStack(spacing: 4) {
            if let saleMark = item.saleMark {
                MarkChip(label: DisplayCodeLabels.saleMark(saleMark))
            }
            if item.isMembers {
                MarkChip(label: DisplayCodeLabels.eventType(item.typeCode))
            }
            if item.isCancelled || item.isCancellationSuspected {
                Text(DisplayCodeLabels.eventState(item.state))
                    .foregroundStyle(Color.secondary)
            }
        }
        .font(.caption2.weight(.semibold))
        .lineLimit(1)
        .fixedSize()
    }
}
