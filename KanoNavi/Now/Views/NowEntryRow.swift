import KanoNaviCore
import SwiftUI

/// One of today's or tomorrow's entries. Tapping it opens the entry in the
/// Schedule tab.
struct NowEntryRow: View {
    let entry: NowEntry

    @Environment(AppRouter.self) private var router
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button {
            router.selectedTab = .schedule
            router.scheduleFocus = .event(id: entry.eventID)
        } label: {
            let layout =
                dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
                : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))
            layout {
                Text(time)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(isPast ? .secondary : .primary)
                    .frame(minWidth: dynamicTypeSize.isAccessibilitySize ? nil : 84, alignment: .leading)

                VStack(alignment: .leading, spacing: 6) {
                    NowTitle(text: entry.title)
                        .strikethrough(entry.state == .cancelled)
                        .foregroundStyle(isPast ? .secondary : .primary)
                    chips
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var isPast: Bool {
        entry.state == .done || entry.state == .cancelled
    }

    private var time: LocalizedStringResource {
        guard let startsAt = entry.startsAt else { return .Now.timeTBA }
        let value = NowTimeFormat.time(startsAt, locale: locale)
        return entry.isApproximate ? .Now.approximateJSTTime(value) : .Now.jstTime(value)
    }

    private var chips: some View {
        NowFlowLayout(spacing: 6) {
            if entry.state == .live {
                NowLiveBadge()
            } else if entry.state != .upcoming {
                NowChip(label: DisplayCodeLabels.eventState(entry.state))
            }
            if let saleMark = entry.saleMark {
                NowChip(label: DisplayCodeLabels.saleMark(saleMark))
            }
            if entry.isMembers {
                NowMembersChip()
            } else if let typeCode = entry.typeCode {
                NowChip(label: DisplayCodeLabels.eventType(typeCode))
            }
            if let activityCode = entry.activityCode {
                NowChip(label: DisplayCodeLabels.activity(activityCode))
            }
        }
    }
}
