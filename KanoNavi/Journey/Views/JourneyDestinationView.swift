import KanoNaviCore
import SwiftUI

/// The screen a Journey destination names, looked up in the loaded Journey.
struct JourneyDestinationView: View {
    let destination: JourneyDestination
    let journey: JourneyResponse

    var body: some View {
        switch destination {
        case .milestone(let id):
            if let milestone = journey.milestones.first(where: { $0.id == id }) {
                JourneyMilestoneDetail(
                    milestone: milestone, branch: journey.branches.first { $0.id == milestone.branch })
            } else {
                ContentUnavailableView {
                    Label {
                        Text(.Journey.milestoneMissingTitle)
                    } icon: {
                        Image(systemName: "calendar.badge.exclamationmark")
                    }
                } description: {
                    Text(.Journey.milestoneMissingMessage)
                }
            }
        }
    }
}
