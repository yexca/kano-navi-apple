import KanoNaviComponents
import SwiftUI

/// An entry in the Details grid: its title on one line, in its tag's color
/// on a tint of it. A done or cancelled entry fades; a cancelled one is also
/// struck through.
struct ScheduleGridEntryTitle: View {
    let mark: ScheduleDayMark

    var body: some View {
        Text(verbatim: mark.title)
            .font(.caption2.weight(.medium))
            .strikethrough(mark.isCancelled)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(mark.tag.color)
            .padding(.horizontal, 3)
            .padding(.vertical, 1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(mark.tag.color.opacity(ScheduleTag.tintOpacity), in: .rect(cornerRadius: 3))
            .opacity(mark.isFaded ? ScheduleTag.fadedOpacity : 1)
    }
}
