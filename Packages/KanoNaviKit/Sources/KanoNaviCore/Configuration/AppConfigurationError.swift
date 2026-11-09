/// Why the Info.plist does not hold a usable configuration.
public enum AppConfigurationError: Error, Equatable, Sendable {
    /// The Info.plist has no string under ``AppConfiguration/apiBaseURLKey``.
    case missingAPIBaseURL

    /// The value is not an absolute HTTPS URL with a host.
    case invalidAPIBaseURL(String)
}
