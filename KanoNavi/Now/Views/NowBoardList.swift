import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The Now tab's sections for one snapshot: the profile card, the spotlight, Coming Up, on-sale
/// items, the latest video and the freshness line.
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
            case .savedCopy(let isUpdating):
                Section {
                    NowSavedCopyNotice(isUpdating: isUpdating, fetchedAt: fetchedAt)
                }
            case nil:
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

            NowComingUpSections(model: comingUp, dashboardEvents: board.events, feedURL: feedURL, now: now)

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

            Section {
            } footer: {
                NowFreshnessFooter(freshness: board.freshness, fetchedAt: fetchedAt, now: now)
            }
        }
    }
}
