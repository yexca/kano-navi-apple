import Foundation
import KanoNaviCore

/// Persists the servers the person added and the selected server in
/// `UserDefaults`.
struct ServerListStore {
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// The saved list around the build's built-in servers. Unreadable saved
    /// servers are dropped.
    func load(builtIn: [ServiceServer]) -> ServerList {
        let custom =
            defaults.data(forKey: AppSettings.customServersKey)
            .flatMap { try? JSONDecoder().decode([ServiceServer].self, from: $0) } ?? []
        return ServerList(
            builtIn: builtIn,
            custom: custom,
            selectedID: defaults.string(forKey: AppSettings.selectedServerKey)
        )
    }

    func save(_ list: ServerList) {
        if let data = try? JSONEncoder().encode(list.custom) {
            defaults.set(data, forKey: AppSettings.customServersKey)
        }
        defaults.set(list.selectedID, forKey: AppSettings.selectedServerKey)
    }
}
