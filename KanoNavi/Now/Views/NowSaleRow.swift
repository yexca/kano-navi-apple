import KanoNaviCore
import SwiftUI

/// One item of the on-sale strip. Tapping it opens the entry in the Schedule
/// tab.
struct NowSaleRow: View {
    let sale: NowSale

    @Environment(AppRouter.self) private var router
    @Environment(\.locale) private var locale

    var body: some View {
        Button {
            router.selectedTab = .schedule
            router.scheduleFocus = .event(id: sale.id)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                NowTitle(text: sale.title)
                    .font(.headline)
                NowFlowLayout(spacing: 6) {
                    NowChip(label: DisplayCodeLabels.eventState(sale.state))
                }
                if let opens = sale.opens {
                    Text(.Now.saleFrom(moment(opens)))
                        .foregroundStyle(.secondary)
                }
                if let closes = sale.closes {
                    Text(.Now.saleUntil(moment(closes)))
                        .foregroundStyle(.secondary)
                }
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private func moment(_ moment: NowSale.Moment) -> String {
        guard let time = moment.time else { return NowTimeFormat.day(moment.date, locale: locale) }
        return String(localized: .Now.jstTime(NowTimeFormat.dateTime(time, locale: locale)))
    }
}
