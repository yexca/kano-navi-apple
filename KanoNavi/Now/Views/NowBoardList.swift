import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The Now tab's sections for one snapshot.
struct NowBoardList: View {
    let board: NowBoard
    let now: Date
    let notice: NowNotice?
    let fetchedAt: Date?
    let retry: () async -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        List {
            switch notice {
            case .failed(let status, let isSavedCopy):
                Section {
                    NowStatusBanner(
                        status: status, isSavedCopy: isSavedCopy, fetchedAt: fetchedAt, retry: retry)
                }
            case .savedCopy(let isUpdating):
                Section {
                    NowSavedCopyNotice(isUpdating: isUpdating, fetchedAt: fetchedAt)
                }
            case nil:
                EmptyView()
            }

            Section {
                if let spotlight = board.spotlight {
                    NowSpotlightTicket(spotlight: spotlight, now: now)
                } else {
                    NowEmptyTicket()
                }
            }

            if let broadcast = board.liveBroadcast {
                Section {
                    NowLiveBroadcastCard(broadcast: broadcast)
                }
            }

            Section {
                entries(board.todayEntries, empty: .Now.nothingToday)
            } header: {
                Text(.Now.todayHeader(JSTTimeFormat.day(board.today, locale: locale)))
            }

            Section {
                entries(board.tomorrowEntries, empty: .Now.nothingTomorrow)
            } header: {
                Text(.Now.tomorrowHeader(JSTTimeFormat.day(board.tomorrow, locale: locale)))
            }

            if board.sales.isEmpty == false {
                Section {
                    ForEach(board.sales) { sale in
                        NowSaleRow(sale: sale)
                    }
                } header: {
                    Text(.Now.salesHeader)
                }
            }

            if let video = board.latestVideo {
                Section {
                    NowVideoCard(video: video)
                } header: {
                    Text(.Now.spotlightLatest)
                }
            }

            NowFreshnessSection(freshness: board.freshness, fetchedAt: fetchedAt)
        }
    }

    @ViewBuilder
    private func entries(_ entries: [NowEntry], empty: LocalizedStringResource) -> some View {
        if entries.isEmpty {
            Text(empty)
                .foregroundStyle(.secondary)
        } else {
            ForEach(entries) { entry in
                NowEntryRow(entry: entry)
            }
        }
    }
}
