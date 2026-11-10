import Foundation

/// The wording the components add, from this module's String Catalog.
///
/// Display-code labels come from `DisplayCodeLabels` in `KanoNaviCore`; this
/// table holds only text the components compose around them.
nonisolated enum ComponentStrings {
    /// The word beside the live indicator's red dot.
    static var live: LocalizedStringResource {
        resource("components.live")
    }

    /// A formatted clock time followed by the Japan time-zone label.
    static func timeJST(_ time: String) -> LocalizedStringResource {
        resource("components.time.jst \(time)")
    }

    /// A formatted date and clock time followed by the Japan time-zone label.
    static func dateTimeJST(date: String, time: String) -> LocalizedStringResource {
        resource("components.time.dateTime \(date) \(time)")
    }

    /// The Japan time-zone label set beside a clock time drawn on its own.
    static var timeZoneJST: LocalizedStringResource {
        resource("components.time.zone")
    }

    /// Stands in for the time of an entry whose time is not known yet.
    static var timeTBA: LocalizedStringResource {
        resource("components.time.tba")
    }

    /// An estimated clock time, such as "About 21:00".
    static func approximateTime(_ time: String) -> LocalizedStringResource {
        resource("components.time.approximate \(time)")
    }

    /// When a live entry ends, such as "Until 23:00".
    static func liveUntil(_ time: String) -> LocalizedStringResource {
        resource("components.ticket.liveUntil \(time)")
    }

    /// When a live entry without an end time started, such as "Since 21:00".
    static func liveSince(_ time: String) -> LocalizedStringResource {
        resource("components.ticket.liveSince \(time)")
    }

    /// Joins an entry's type and tag, such as "Stream · Gameplay".
    static func joined(_ first: String, _ second: String) -> LocalizedStringResource {
        resource("components.ticket.joined \(first) \(second)")
    }

    private static func resource(_ value: String.LocalizationValue) -> LocalizedStringResource {
        LocalizedStringResource(value, table: nil, bundle: bundleDescription)
    }

    private static let bundleDescription = LocalizedStringResource.BundleDescription.atURL(
        Bundle.module.bundleURL)
}
