/// A Kano Navi service the app ships with. Its address comes from the build
/// configuration (`AppConfiguration`); the app localizes its name.
public enum BuiltInServer: String, CaseIterable, Sendable {
    /// The service in Japan, at `API_BASE_URL`. It is the default.
    case japan
    /// The service in mainland China, at `MAINLAND_API_BASE_URL`.
    case mainlandChina
}
