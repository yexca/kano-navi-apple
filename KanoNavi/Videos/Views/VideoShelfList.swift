import KanoNaviCore
import SwiftUI

/// The Videos tab's shelf for one snapshot: the lead, then reservations,
/// works, stream archives and Shorts in the projection's order, under the
/// kind and platform filter pinned in the bar area, and the link to the
/// month archive.
struct VideoShelfList: View {
    let shelf: VideoShelf
    let dashboard: DashboardStore
    let showsArchive: Bool

    /// The chosen kind's code, or `nil` for every kind.
    @State private var kind: String?
    @State private var platform: VideoShelfPlatform?

    var body: some View {
        let filter = shelf.resolved(
            VideoShelfFilter(kind: kind.flatMap(VideoShelfKind.init(rawValue:)), platform: platform))
        let shown = shelf.narrowed(by: filter)
        let kindOptions = shelf.kindOptions(on: filter.platform, selected: filter.kind)
        let platforms = shelf.platforms
        List {
            DashboardNoticeSection(dashboard: dashboard)

            if let lead = shown.lead {
                Section {
                    VideoLeadCard(card: lead, isFeatured: shown.leadIsFeatured)
                } header: {
                    Text(shown.leadIsFeatured ? .Videos.featured : .Videos.latestWork)
                }
            }

            VideoShelfSection(title: .Videos.comingUp, cards: shown.reservations)
            VideoShelfSection(title: .Videos.works, cards: shown.works)
            VideoShelfSection(title: .Videos.archives, cards: shown.archives)

            if shown.shorts.isEmpty == false {
                Section {
                    VideoShortsRow(cards: shown.shorts)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                } header: {
                    Text(.Videos.shorts)
                }
            }

            if shown.isEmpty {
                Section {
                    Text(shelf.isEmpty ? .Videos.shelfEmpty : .Videos.filterEmpty)
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
        // On the scroll view alone: around the bar, the filter row's own
        // scroll view would take a refresh control's room and hide its chips.
        .refreshable(action: dashboard.refresh)
        .safeAreaBar(edge: .top) {
            if kindOptions.isEmpty == false || platforms.count > 1 {
                VideoShelfFilterBar(
                    options: kindOptions, kind: $kind, platforms: platforms, platform: $platform)
            }
        }
        // A firm edge under the chips, so cards never show through them.
        .scrollEdgeEffectStyle(.hard, for: .top)
        // A large title would scroll under the pinned row's firm edge.
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: filter) {
            // A choice the shelf no longer offers goes back to all.
            kind = filter.kind?.rawValue
            platform = filter.platform
        }
    }
}
