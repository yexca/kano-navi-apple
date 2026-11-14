import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The Now tab's sections for one snapshot: the profile card, the spotlight, Coming Up, on-sale
/// items and the freshness line.
struct NowBoardList: View {
    let board: NowBoard
    let comingUp: NowComingUpModel
    let feedURL: URL?
    let now: Date
    let notice: NowNotice?
    let fetchedAt: Date?
    let retry: () async -> Void

    var body: some View {
        List {
            switch notice {
            case .failed(let status, let isSavedCopy):
                Section {
                    NowStatusBanner(
                        status: status, isSavedCopy: isSavedCopy, fetchedAt: fetchedAt, retry: retry)
                }
            case .savedCopy, nil:
                // The saved copy's "Updating…" floats over the list
                // (`NowSavedCopyNotice`), so the board does not move for it.
                EmptyView()
            }

            Section {
                NowProfileCard(profile: board.profile)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(NowProfileCard.background)
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

            NowComingUpSections(
                model: comingUp, dashboardEvents: board.events, shownAbove: board.shownAbove,
                feedURL: feedURL,
                now: now)

            if board.sales.isEmpty == false {
                Section {
                    ForEach(board.sales) { sale in
                        NowSaleRow(sale: sale)
                    }
                } header: {
                    Text(.Now.salesHeader)
                }
            }

            Section {
            } footer: {
                NowFreshnessFooter(freshness: board.freshness, fetchedAt: fetchedAt, now: now)
            }
        }
        // Only real changes move rows, and they move quietly: a banner for a
        // failed refresh, or Coming Up entries that differ from the cached
        // ones. An identical read publishes nothing.
        // The cover images at the top are drawn on the first frame when the
        // disk cache has them, instead of popping in a frame later.
        .environment(\.mediaImageDecodesCachedFilesAtOnce, true)
        .animation(.default, value: notice)
        .animation(.default, value: comingUp.result)
    }
}
