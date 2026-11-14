import KanoNaviCore
import SwiftUI

/// The milestones, oldest first, under a sticky header per year.
struct JourneyTimelineList: View {
    let journey: JourneyResponse
    @Binding var branch: String?
    let notice: DocumentNotice?
    let reload: () async -> Void

    var body: some View {
        let groups = JourneyTimeline.groups(journey.milestones, branch: branch)
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
                    }
                }

                if groups.isEmpty {
                    JourneyEmptyNote(message: .Journey.timelineEmpty)
                }
                JourneyFooter(updatedAt: journey.updatedAt)
            }
        }
        .refreshable {
            await reload()
        }
    }
}
