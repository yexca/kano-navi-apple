import KanoNaviCore
import SwiftUI

/// The color family of a schedule entry, from its `view.typeCode`, or its
/// `eventType` when the service leaves the type code out because an
/// activity label stands in for a plain stream. The app's
/// calendar and the widgets draw an entry in its tag's color; the type's name
/// stays in words in the entry's chips, so color never stands alone. An
/// unknown or missing code is `other`. Safe in widgets.
nonisolated public enum ScheduleTag: String, Equatable, CaseIterable, Sendable {
    case stream
    case member
    case event
    case release
    case video
    case sale
    case other

    /// The opacity of the tag's color behind a title, as in the app's
    /// Details grid. Tag text stays at 4.5:1 or more on it in both
    /// appearances.
    public static let tintOpacity = 0.14

    /// The opacity of a done or cancelled entry's marks, which keep their
    /// hue but fade.
    public static let fadedOpacity = 0.55

    public init(typeCode: String?) {
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

    /// The tag of an entry with a `view`; one without a view is `other`.
    public init(event: ScheduleEvent) {
        guard let view = event.view else {
            self = .other
            return
        }
        self.init(typeCode: view.typeCode ?? event.eventType)
    }

    /// Whether an entry in `state` is over or called off, so its marks fade.
    public static func isFaded(_ state: EventState) -> Bool {
        state == .done || state == .cancelled
    }

    /// The color asset's name in this package's catalog. Streams use the
    /// app's Berry.
    public var colorName: String {
        "ScheduleTag" + rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    /// The tag's color for text, marks and bars, in light and dark
    /// appearance. Text in it stays at 4.5:1 or more on the system
    /// background and on the widgets' backgrounds.
    public var color: Color {
        Color(colorName, bundle: #bundle)
    }
}

nonisolated extension ScheduleEvent {
    /// Whether the entry is over or called off, so its marks fade.
    public var isFadedInSchedule: Bool {
        ScheduleTag.isFaded(displayState)
    }
}
