/// `UserDefaults` keys for the app's settings, read with `@AppStorage`,
/// `NotificationPreferencesStore`, or `ServerListStore`.
nonisolated enum AppSettings {
    /// The content language, a `ContentLanguage` raw value; `system` by default.
    static let contentLanguageKey = "contentLanguage"
    /// JSON-encoded `NotificationPreferences`.
    static let notificationPreferencesKey = "notificationPreferences"
    /// The Schedule tab's mode, a `ScheduleMode` raw value; `list` by default.
    static let scheduleModeKey = "scheduleMode"
    /// The selected server's `ServiceServer` ID; the default built-in server
    /// when unset.
    static let selectedServerKey = "selectedServer"
    /// JSON-encoded `[ServiceServer]`, the servers the person added.
    static let customServersKey = "customServers"
}
