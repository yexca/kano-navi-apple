import KanoNaviCore

/// The choices of the content language picker, in display order.
enum ContentLanguageOption {
    static let all: [ContentLanguage] = [.system, .en, .ja, .zhHans]

    /// A language's own name, which is not translated, or `nil` for
    /// ``ContentLanguage/system``, whose label is localized.
    static func autonym(of language: ContentLanguage) -> String? {
        switch language {
        case .system: nil
        case .en: "English"
        case .ja: "日本語"
        case .zhHans: "简体中文"
        }
    }
}
