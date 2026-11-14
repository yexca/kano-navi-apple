import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// An entry in the Details grid: its title on one line, in its tag's color
/// on a tint of it. A done or cancelled entry fades; a cancelled one is also
/// struck through.
struct ScheduleGridEntryTitle: View {
    let item: ScheduleDayEntry
    let contentLanguage: ContentLanguage

    @Environment(\.locale) private var locale

    var body: some View {
        let tag = ScheduleTag(event: item.event)
        Text(verbatim: item.event.resolvedTitle(preference: contentLanguage, interfaceLocale: locale).text)
            .font(.caption2.weight(.medium))
            .strikethrough(item.event.isCancelled)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(tag.color)
            .padding(.horizontal, 3)
            .padding(.vertical, 1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tag.color.opacity(ScheduleTag.tintOpacity), in: .rect(cornerRadius: 3))
            .opacity(item.event.isFadedInSchedule ? ScheduleTag.fadedOpacity : 1)
    }
}
