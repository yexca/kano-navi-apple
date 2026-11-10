import Foundation

/// The name of one archive filter: a translated code, such as a video
/// category, or a name shown as written, such as an `@handle`.
nonisolated enum ArchiveFilterLabel: Equatable, Sendable {
    case localized(LocalizedStringResource)
    case verbatim(String)
}
