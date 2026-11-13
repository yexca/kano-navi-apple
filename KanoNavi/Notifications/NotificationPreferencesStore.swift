import Foundation
import KanoNaviCore

/// Persists `NotificationPreferences` in `UserDefaults`.
struct NotificationPreferencesStore {
    let defaults: UserDefaults
    let key: String

    init(
        defaults: UserDefaults = .standard,
        key: String = AppSettings.notificationPreferencesKey
    ) {
        self.defaults = defaults
        self.key = key
    }

    func load() -> NotificationPreferences {
        guard let data = defaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode(NotificationPreferences.self, from: data)
        else {
            return NotificationPreferences()
        }
        return decoded
    }

    func save(_ preferences: NotificationPreferences) {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        defaults.set(data, forKey: key)
    }
}
