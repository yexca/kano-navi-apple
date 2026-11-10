import Foundation

/// A More screen that is not built yet. The list shows it as coming later.
enum MoreUpcomingFeature: CaseIterable, Identifiable {
    case works
    case journey
    case lineBlog

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .works: .More.moreWorks
        case .journey: .More.moreJourney
        case .lineBlog: .More.moreLineBlog
        }
    }

    var systemImage: String {
        switch self {
        case .works: "music.note.list"
        case .journey: "point.bottomleft.forward.to.point.topright.scurvepath"
        case .lineBlog: "book.closed"
        }
    }
}
