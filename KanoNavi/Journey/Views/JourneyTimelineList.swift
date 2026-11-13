import KanoNaviCore
import SwiftUI

/// The milestones, oldest first, under a sticky header per year. The toolbar
/// jumps to the latest milestones or to any year.
struct JourneyTimelineList: View {
    let journey: JourneyResponse
    @Binding var branch: String?
    let notice: DocumentNotice?
    let reload: () async -> Void

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
                                .id(group.year)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    JourneyYearMenu(years: groups.map(\.year)) { year in
                        jump(to: year, with: proxy)
                    }
                }
            }
        }
    }

    /// Scrolls a year's header to the top. The lazy stack only estimates
    /// the rows it has not drawn yet, so the first scroll can stop short of
    /// a distant year; a second one, once those rows are measured, lands on
    /// it.
    private func jump(to year: Int, with proxy: ScrollViewProxy) {
        proxy.scrollTo(year, anchor: .top)
        Task {
            try? await Task.sleep(for: .milliseconds(120))
            withAnimation {
                proxy.scrollTo(year, anchor: .top)
            }
        }
    }
}
