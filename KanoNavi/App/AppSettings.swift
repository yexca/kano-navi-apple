/// `UserDefaults` keys for the app's settings, read with `@AppStorage` or
/// `NotificationPreferencesStore`.
nonisolated enum AppSettings {
    /// The content language, a `ContentLanguage` raw value; `system` by default.
    static let contentLanguageKey = "contentLanguage"
    /// JSON-encoded `NotificationPreferences`.
    static let notificationPreferencesKey = "notificationPreferences"
}
