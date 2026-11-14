import KanoNaviCore
import SwiftUI

/// The milestones of the chosen identity, oldest first, by year. The
/// navigation subtitle names the year at the top and its milestone count,
/// the year alone at accessibility text sizes. The first year has no header,
/// since the subtitle names it; each later one opens with its
/// `JourneyYearHeader`, which scrolls with the milestones. Each row is
/// identified by its `JourneyTimelineSlot`.
struct JourneyTimelineList: View {
    let journey: JourneyResponse
    let branch: String?
    let notice: DocumentNotice?
    let reload: () async -> Void

    /// The year of the first group with a milestone on screen, once one is,
    /// for the branch filter it was read under.
    @State private var top: TopYear?

    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let groups = JourneyTimeline.groups(journey.milestones, branch: branch)
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if let notice {
                    JourneyNotice(notice: notice, reload: reload)
                        .padding(.vertical, 8)
                }

                ForEach(groups) { group in
                    Section {
                        ForEach(group.milestones) { milestone in
                            NavigationLink(value: JourneyDestination.milestone(milestone.id)) {
                                JourneyMilestoneRow(
                                    milestone: milestone,
                                    branch: journey.branches.first { $0.id == milestone.branch })
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("journey.milestone." + milestone.id)
                            .id(JourneyTimelineSlot(year: group.year, milestoneID: milestone.id))
                        }
                    } header: {
                        if group.year != groups.first?.year {
                            JourneyYearHeader(year: group.year, count: group.milestones.count)
                        }
                    }
                }

                if groups.isEmpty {
                    JourneyEmptyNote(message: .Journey.timelineEmpty)
                }
                JourneyFooter(updatedAt: journey.updatedAt)
            }
            .scrollTargetLayout()
        }
        // Reports only when a milestone comes on or goes off screen, and sets
        // the state only when the top year or the filter changes. The rows run
        // under the navigation bar and the identity chips, so a milestone
        // counts while 30% of it shows: about until it slides under them.
        .onScrollTargetVisibilityChange(idType: JourneyTimelineSlot.self, threshold: 0.3) { slots in
            guard let year = JourneyTimeline.topYear(of: groups, visible: slots) else { return }
            let new = TopYear(branch: branch, year: year)
            if new != top {
                top = new
            }
        }
        .navigationSubtitle(subtitle(groups) ?? Text(verbatim: ""))
        .refreshable {
            await reload()
        }
    }

    /// The year at the top, or the first year until a milestone of the
    /// current branch filter is on screen, with its milestone count; `nil`
    /// without milestones. A year read under another filter is never shown.
    private func subtitle(_ groups: [JourneyYearGroup]) -> Text? {
        let topYear = top.flatMap { $0.branch == branch ? $0.year : nil }
        guard let group = groups.first(where: { $0.year == topYear }) ?? groups.first else { return nil }
        let year = String(group.year)
        if dynamicTypeSize.isAccessibilitySize {
            return Text(verbatim: year)
        }
        var count = LocalizedStringResource.Journey.milestoneCount(group.milestones.count)
        count.locale = locale
        return Text(verbatim: year + " · " + String(localized: count))
    }

    /// A top year and the branch filter its rows were listed under.
    private struct TopYear: Equatable {
        let branch: String?
        let year: Int
    }
}
