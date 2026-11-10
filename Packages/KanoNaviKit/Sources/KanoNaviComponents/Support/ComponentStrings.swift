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

    /// The name of the `other` platform: a web page such as a shop or a post.
    static var otherPlatform: LocalizedStringResource {
        resource("components.platform.other")
    }

    /// A formatted clock time followed by the Japan time-zone label.
    static func timeJST(_ time: String) -> LocalizedStringResource {
        resource("components.time.jst \(time)")
    }

    /// A formatted date and clock time followed by the Japan time-zone label.
    static func dateTimeJST(date: String, time: String) -> LocalizedStringResource {
        resource("components.time.dateTime \(date) \(time)")
    }

    private static func resource(_ value: String.LocalizationValue) -> LocalizedStringResource {
        LocalizedStringResource(value, table: nil, bundle: bundleDescription)
    }

    private static let bundleDescription = LocalizedStringResource.BundleDescription.atURL(
        Bundle.module.bundleURL)
}
