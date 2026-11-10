import KanoNaviCore
import SwiftUI

/// The Now tab's sections for one snapshot.
struct NowBoardList: View {
    let board: NowBoard
    let now: Date
    let status: NowStatus?
    let fetchedAt: Date?
    let retry: () async -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        List {
            if let status {
                Section {
                    NowStatusBanner(status: status, fetchedAt: fetchedAt, retry: retry)
                }
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
                Text(.Now.todayHeader(NowTimeFormat.day(board.today, locale: locale)))
            }

            Section {
                entries(board.tomorrowEntries, empty: .Now.nothingTomorrow)
            } header: {
                Text(.Now.tomorrowHeader(NowTimeFormat.day(board.tomorrow, locale: locale)))
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
