import Foundation

/// Localized labels for API display codes. Unknown values use a neutral label.
public enum DisplayCodeLabels {
    public static func eventState(_ code: EventState) -> LocalizedStringResource {
        resource(eventStates.key(for: code.rawValue))
    }

    public static func eventType(_ code: String?) -> LocalizedStringResource {
        resource(eventTypes.key(for: code))
    }

    public static func activity(_ code: String?) -> LocalizedStringResource {
        resource(activities.key(for: code))
    }

    public static func tag(_ code: String?) -> LocalizedStringResource {
        activity(code)
    }

    public static func platform(_ code: EventPlatform) -> LocalizedStringResource {
        resource(platforms.key(for: code.rawValue))
    }

    public static func videoPhase(_ code: VideoPhase) -> LocalizedStringResource {
        resource(videoPhases.key(for: code.rawValue))
    }

    public static func form(_ code: VideoFormCode?) -> LocalizedStringResource {
        resource(videoForms.key(for: code?.rawValue))
    }

    public static func availability(_ code: VideoAvailability?) -> LocalizedStringResource {
        resource(availabilities.key(for: code?.rawValue))
    }

    public static func saleMark(_ code: SaleMark?) -> LocalizedStringResource {
        resource(saleMarks.key(for: code?.rawValue))
    }

    public static func translationOrigin(_ code: TranslationOrigin?) -> LocalizedStringResource {
        resource(translationOrigins.key(for: code?.rawValue))
    }

    public static func syncStatus(_ code: String?) -> LocalizedStringResource {
        resource(syncStatuses.key(for: code))
    }

    /// Every String Catalog key the labels can produce, including each
    /// family's `unknown` key.
    static var allKeys: [String] {
        families.flatMap(\.keys)
    }

    private static func resource(_ key: String) -> LocalizedStringResource {
        LocalizedStringResource(
            String.LocalizationValue(key),
            table: nil,
            bundle: .atURL(KanoNaviResources.bundle.bundleURL)
        )
    }

    /// The codes of one display-code family and their catalog key prefix.
    private struct Family {
        let prefix: String
        let codes: Set<String>

        /// The key for a code; a missing or unrecognized code is `unknown`.
        func key(for code: String?) -> String {
            guard let code, codes.contains(code) else { return prefix + "unknown" }
            return prefix + code
        }

        var keys: [String] {
            (codes.sorted() + ["unknown"]).map { prefix + $0 }
        }
    }

    private static let families = [
        eventStates, eventTypes, activities, platforms, videoPhases, videoForms, availabilities,
        saleMarks, translationOrigins, syncStatuses,
    ]

    private static let eventStates = Family(
        prefix: "event.state.",
        codes: ["upcoming", "live", "open", "done", "pending", "cancelled", "cancellation_review"])
    private static let eventTypes = Family(
        prefix: "event.type.", codes: ["stream", "member", "event", "release", "video", "sale"])
    private static let activities = Family(
        prefix: "event.tag.", codes: ["live", "game", "talk", "song", "video"])
    private static let platforms = Family(prefix: "platform.", codes: ["youtube", "bilibili", "other"])
    private static let videoPhases = Family(
        prefix: "video.phase.", codes: ["upcoming", "live", "started", "past", "cancelled"])
    private static let videoForms = Family(
        prefix: "video.form.", codes: ["short", "upcoming", "stream", "archive", "premiere", "video"])
    private static let availabilities = Family(
        prefix: "video.availability.", codes: ["public", "unlisted", "members", "private", "removed"])
    private static let saleMarks = Family(prefix: "sale.", codes: ["opens", "closes"])
    private static let translationOrigins = Family(
        prefix: "translation.origin.", codes: ["manual", "platform", "machine"])
    private static let syncStatuses = Family(
        prefix: "sync.", codes: ["ok", "success", "partial", "running", "failed", "none"])
}
