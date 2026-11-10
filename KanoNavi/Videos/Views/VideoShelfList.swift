import KanoNaviCore
import SwiftUI

/// The Videos tab's shelf for one snapshot: the lead, then reservations,
/// works, stream archives and Shorts in the projection's order, and the link
/// to the month archive.
struct VideoShelfList: View {
    let shelf: VideoShelf
    let dashboard: DashboardStore
    let showsArchive: Bool

    var body: some View {
        List {
            DashboardNoticeSection(dashboard: dashboard)

            if let lead = shelf.lead {
                Section {
                    VideoLeadCard(card: lead, isFeatured: shelf.leadIsFeatured)
                } header: {
                    Text(shelf.leadIsFeatured ? .Videos.featured : .Videos.latestWork)
                }
            }

            VideoShelfSection(title: .Videos.comingUp, cards: shelf.reservations)
            VideoShelfSection(title: .Videos.works, cards: shelf.works)
            VideoShelfSection(title: .Videos.archives, cards: shelf.archives)

            if shelf.shorts.isEmpty == false {
                Section {
                    VideoShortsRow(cards: shelf.shorts)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                } header: {
                    Text(.Videos.shorts)
                }
            }

            if shelf.isEmpty {
                Section {
                    Text(.Videos.shelfEmpty)
                        .foregroundStyle(.secondary)
                }
            }

            if showsArchive {
                Section {
                    NavigationLink(value: VideosDestination.archive) {
                        Label {
                            Text(.Videos.pastVideos)
                        } icon: {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                    .accessibilityIdentifier("videos.archive")
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
