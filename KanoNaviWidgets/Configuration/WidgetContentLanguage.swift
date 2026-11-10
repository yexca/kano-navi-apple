import AppIntents
import KanoNaviCore

/// The content language a widget shows titles in. The widget cannot read the
/// app's setting without an App Group, so each widget chooses its own.
nonisolated enum WidgetContentLanguage: String, AppEnum {
    case sameAsApp
    case english
    case japanese
    case simplifiedChinese

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "widgetLanguageType"

    static let caseDisplayRepresentations: [WidgetContentLanguage: DisplayRepresentation] = [
        .sameAsApp: "widgetLanguageSameAsApp",
        .english: "widgetLanguageEnglish",
        .japanese: "widgetLanguageJapanese",
        .simplifiedChinese: "widgetLanguageSimplifiedChinese",
    ]

    var contentLanguage: ContentLanguage {
        switch self {
        case .sameAsApp: .system
        case .english: .en
        case .japanese: .ja
        case .simplifiedChinese: .zhHans
        }
    }
}
