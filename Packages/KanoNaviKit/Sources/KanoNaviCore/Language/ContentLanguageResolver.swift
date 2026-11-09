import Foundation

public enum ContentLanguageResolver {
  public static func locale(for preference: ContentLanguage, interfaceLocale: Locale = .current)
    -> ContentLocale
  {
    switch preference {
    case .system: ContentLocale(interfaceLocale: interfaceLocale)
    case .en: .en
    case .ja: .ja
    case .zhHans: .zhHans
    }
  }

  public static func resolve(
    original: String, sourceLanguage: String?, translations: Translations?,
    preference: ContentLanguage, interfaceLocale: Locale = .current
  ) -> ResolvedContentText {
    let locale = locale(for: preference, interfaceLocale: interfaceLocale)
    if locale == .ja, sourceLanguage?.lowercased().hasPrefix("ja") == true {
      return ResolvedContentText(
        text: original, isTranslation: false, origin: nil, original: original)
    }
    if let translation = translations?[locale], translation.text.isEmpty == false {
      return ResolvedContentText(
        text: translation.text, isTranslation: true, origin: translation.origin, original: original)
    }
    return ResolvedContentText(
      text: original, isTranslation: false, origin: nil, original: original)
  }
}
