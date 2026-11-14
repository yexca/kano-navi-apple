import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The color family of an entry, from its `view.typeCode`. Every grid and
/// the List mode's rows draw an entry in its tag's color; the type's name
/// stays in words in the detail sheet, so color never stands alone. An
/// unknown or missing code is `other`.
nonisolated enum ScheduleTag: Equatable, CaseIterable {
    case stream
    case member
    case event
    case release
    case video
    case sale
    case other

    /// The opacity of the tag's color behind a title in the Details grid.
    /// Tag text stays at 4.5:1 or more on it in both appearances.
    static let tintOpacity = 0.14

    /// The opacity of a done or cancelled entry's marks, which keep their
    /// hue but fade.
    static let fadedOpacity = 0.55

    init(typeCode: String?) {
        self =
            switch typeCode {
            case "stream": .stream
            case "member": .member
            case "event": .event
            case "release": .release
            case "video": .video
            case "sale": .sale
            default: .other
            }
    }

    init(event: ScheduleEvent) {
        self.init(typeCode: event.view?.typeCode)
    }

    /// The tag's color asset. Streams use the app's Berry.
    @MainActor var colorResource: ColorResource {
        switch self {
        case .stream: .journeyBerry
        case .member: .scheduleTagMember
        case .event: .scheduleTagEvent
        case .release: .scheduleTagRelease
        case .video: .scheduleTagVideo
        case .sale: .scheduleTagSale
        case .other: .scheduleTagOther
        }
    }

    /// The tag's color for text, marks and bars, in light and dark appearance.
    @MainActor var color: Color {
        Color(colorResource)
    }
}

nonisolated extension ScheduleEvent {
    /// Whether the entry is over or called off, so its marks fade.
    var isFadedInSchedule: Bool {
        displayState == .done || displayState == .cancelled
    }
}
