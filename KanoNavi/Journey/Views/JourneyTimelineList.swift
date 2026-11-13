import KanoNaviCore
import SwiftUI

/// The milestones, oldest first, under a sticky header per year. The toolbar
/// jumps to the latest milestones or to any year.
struct JourneyTimelineList: View {
    let journey: JourneyResponse
    @Binding var branch: String?
    let notice: DocumentNotice?
    let reload: () async -> Void

    /// The year header a jump is heading for, until the scroll settles.
    @State private var pendingJump: JourneyYearAnchor?

    var body: some View {
        let groups = JourneyTimeline.groups(journey.milestones, branch: branch)
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    JourneyListHeader(
                        branches: journey.branches, branch: $branch,
                        counts: JourneyTimeline.milestoneCounts(journey.milestones),
                        total: journey.milestones.count, countLabel: { .Journey.milestoneCount($0) },
                        notice: notice, reload: reload)

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
                            }
                        } header: {
                            JourneyYearHeader(year: group.year, count: group.milestones.count)
                                .id(JourneyYearAnchor(year: group.year))
                        }
                    }

                    if groups.isEmpty {
                        JourneyEmptyNote(message: .Journey.timelineEmpty)
                    } else {
                        JourneyStoryContinues()
                    }
                    JourneyFooter(updatedAt: journey.updatedAt)
                }
            }
            .refreshable {
                await reload()
            }
            .onScrollPhaseChange { _, phase in
                settleJump(in: phase, with: proxy)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    JourneyYearMenu(years: groups.map(\.year)) { year in
                        jump(to: year, with: proxy)
                    }
                }
            }
        }
    }

    /// Scrolls a year's header to the top.
    private func jump(to year: Int, with proxy: ScrollViewProxy) {
        let anchor = JourneyYearAnchor(year: year)
        pendingJump = anchor
        withAnimation {
            proxy.scrollTo(anchor, anchor: .top)
        }
    }

    /// Finishes a jump. The lazy stack places rows it has not measured yet
    /// by an estimate, so a jump into an unread part of the list can stop
    /// short; once that scroll settles, the rows around the target are
    /// measured and one more scroll lands on the header. Touching the list
    /// drops the pending jump.
    private func settleJump(in phase: ScrollPhase, with proxy: ScrollViewProxy) {
        switch phase {
        case .interacting:
            pendingJump = nil
        case .idle:
            guard let anchor = pendingJump else { return }
            pendingJump = nil
            withAnimation {
                proxy.scrollTo(anchor, anchor: .top)
            }
        default:
            break
        }
    }
}
