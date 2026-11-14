import KanoNaviCore
import SwiftUI

/// The large widget's card for the live or next entry, on a faint Berry fill:
/// its state, when it starts and its time across the top, then its title and
/// marks at full width.
struct HeroCard: View {
    let item: WidgetItem
    let now: Date
    let today: JapanDate

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                StatusCapsule(isLive: item.isLive(at: now))
                if item.isLive(at: now) == false {
                    EntryWhen(item: item, now: now, today: today)
                }
                Spacer(minLength: 4)
                HeroTime(item: item, now: now, alignment: .trailing)
                    .layoutPriority(1)
            }
            EntryTitle(item: item, lineLimit: 2)
                .font(.headline)
            EntryMarks(item: item)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .berryTint(0.12, in: .rect(cornerRadius: 16))
        // The list below gives way first.
        .fixedSize(horizontal: false, vertical: true)
    }
}
