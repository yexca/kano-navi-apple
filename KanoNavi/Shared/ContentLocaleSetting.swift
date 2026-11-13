import KanoNaviCore
import SwiftUI

/// The language content is shown in: the Settings choice, or the interface
/// language when the choice is Same as App.
///
///     @ContentLocaleSetting private var contentLocale
///
///     Text(verbatim: title.resolved(for: contentLocale)?.text ?? "")
///
/// A view that reads it is drawn again when the setting or the interface
/// language changes.
@propertyWrapper
struct ContentLocaleSetting: DynamicProperty {
    @AppStorage(AppSettings.contentLanguageKey) private var preference: ContentLanguage = .system
    @Environment(\.locale) private var locale

    var wrappedValue: ContentLocale {
        ContentLanguageResolver.locale(for: preference, interfaceLocale: locale)
    }
}
