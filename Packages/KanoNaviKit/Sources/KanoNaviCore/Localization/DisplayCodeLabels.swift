import Foundation

/// Localized labels for API display codes. Unknown values use a neutral label.
public enum DisplayCodeLabels {
  public static func eventState(_ code: EventState) -> LocalizedStringResource {
    resource("event.state." + known(code.rawValue, values: eventStates))
  }

  public static func eventType(_ code: String?) -> LocalizedStringResource {
    resource("event.type." + known(code, values: eventTypes))
  }

  public static func activity(_ code: String?) -> LocalizedStringResource {
    resource("event.tag." + known(code, values: activities))
  }

  public static func tag(_ code: String?) -> LocalizedStringResource {
    activity(code)
  }

  public static func platform(_ code: EventPlatform) -> LocalizedStringResource {
    resource("platform." + known(code.rawValue, values: platforms))
  }

  public static func videoPhase(_ code: VideoPhase) -> LocalizedStringResource {
    resource("video.phase." + known(code.rawValue, values: videoPhases))
  }

  public static func form(_ code: VideoFormCode?) -> LocalizedStringResource {
    resource("video.form." + known(code?.rawValue, values: videoForms))
  }

  public static func availability(_ code: VideoAvailability?) -> LocalizedStringResource {
    resource("video.availability." + known(code?.rawValue, values: availabilities))
  }

  public static func saleMark(_ code: SaleMark?) -> LocalizedStringResource {
    resource("sale." + known(code?.rawValue, values: saleMarks))
  }

  public static func translationOrigin(_ code: TranslationOrigin?) -> LocalizedStringResource {
    resource("translation.origin." + known(code?.rawValue, values: translationOrigins))
  }

  public static func syncStatus(_ code: String?) -> LocalizedStringResource {
    resource("sync." + known(code, values: syncStatuses))
  }

  private static func resource(_ key: String) -> LocalizedStringResource {
    LocalizedStringResource(
      String.LocalizationValue(key),
      table: nil,
      bundle: .atURL(KanoNaviResources.bundle.bundleURL)
    )
  }

  private static func known(_ code: String?, values: Set<String>) -> String {
    guard let code, values.contains(code) else {
      return "unknown"
    }
    return code
  }

  private static let eventStates: Set<String> = [
    "upcoming", "live", "open", "done", "pending", "cancelled", "cancellation_review",
  ]
  private static let eventTypes: Set<String> = [
    "stream", "member", "event", "release", "video", "sale",
  ]
  private static let activities: Set<String> = ["live", "game", "talk", "song", "video"]
  private static let platforms: Set<String> = ["youtube", "bilibili", "other"]
  private static let videoPhases: Set<String> = [
    "upcoming", "live", "started", "past", "cancelled",
  ]
  private static let videoForms: Set<String> = [
    "short", "upcoming", "stream", "archive", "premiere", "video",
  ]
  private static let availabilities: Set<String> = [
    "public", "unlisted", "members", "private", "removed",
  ]
  private static let saleMarks: Set<String> = ["opens", "closes"]
  private static let translationOrigins: Set<String> = ["manual", "platform", "machine"]
  private static let syncStatuses: Set<String> = [
    "ok", "success", "partial", "running", "failed", "none",
  ]
}
