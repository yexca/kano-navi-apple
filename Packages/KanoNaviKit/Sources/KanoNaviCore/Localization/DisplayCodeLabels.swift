import Foundation

/// Localized labels for API display codes. Unknown values use a neutral label.
public enum DisplayCodeLabels {
    public static func eventState(_ code: EventState) -> LocalizedStringResource { resource("event.state.\(known(code.rawValue, values: ["upcoming", "live", "open", "done", "pending", "cancelled", "cancellation_review"]))", fallback: "Unknown") }
    public static func eventType(_ code: String?) -> LocalizedStringResource { resource("event.type.\(known(code, values: ["stream", "member", "event", "release", "video", "sale"]))", fallback: "Unknown") }
    public static func activity(_ code: String?) -> LocalizedStringResource { resource("event.tag.\(known(code, values: ["live", "game", "talk", "song", "video"]))", fallback: "Unknown") }
    public static func tag(_ code: String?) -> LocalizedStringResource { activity(code) }
    public static func platform(_ code: EventPlatform) -> LocalizedStringResource { resource("platform.\(known(code.rawValue, values: ["youtube", "bilibili", "other"]))", fallback: "Unknown") }
    public static func videoPhase(_ code: VideoPhase) -> LocalizedStringResource { resource("video.phase.\(known(code.rawValue, values: ["upcoming", "live", "started", "past", "cancelled"]))", fallback: "Unknown") }
    public static func form(_ code: VideoFormCode?) -> LocalizedStringResource { resource("video.form.\(known(code?.rawValue, values: ["short", "upcoming", "stream", "archive", "premiere", "video"]))", fallback: "Unknown") }
    public static func availability(_ code: VideoAvailability?) -> LocalizedStringResource { resource("video.availability.\(known(code?.rawValue, values: ["public", "unlisted", "members", "private", "removed"]))", fallback: "Unknown") }
    public static func saleMark(_ code: SaleMark?) -> LocalizedStringResource { resource("sale.\(known(code?.rawValue, values: ["opens", "closes"]))", fallback: "Unknown") }
    public static func translationOrigin(_ code: TranslationOrigin?) -> LocalizedStringResource { resource("translation.origin.\(known(code?.rawValue, values: ["manual", "platform", "machine"]))", fallback: "Unknown") }
    public static func syncStatus(_ code: String?) -> LocalizedStringResource { resource("sync.\(known(code, values: ["ok", "success", "partial", "running", "failed", "none"]))", fallback: "Unknown") }

    private static func resource(_ key: String, fallback _: String) -> LocalizedStringResource {
        LocalizedStringResource(stringLiteral: key)
    }

    private static func known(_ code: String?, values: Set<String>) -> String { guard let code, values.contains(code) else { return "unknown" }; return code }
}
