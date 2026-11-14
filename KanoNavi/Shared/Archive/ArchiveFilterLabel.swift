import Foundation

/// The name of one archive filter: a translated code, such as a video
/// category, or a name shown as written, such as an `@handle`.
nonisolated enum ArchiveFilterLabel: Equatable, Sendable {
    case localized(LocalizedStringResource)
    case verbatim(String)

    /// The name as text in a locale.
    func text(locale: Locale) -> String {
        switch self {
        case .localized(var resource):
            resource.locale = locale
            return String(localized: resource)
        case .verbatim(let string):
            return string
        }
    }
}
