import KanoNaviCore
import SwiftUI

/// An upload card's title: a collection song as written, a newer video's
/// title in the content language as the Videos tab shows it.
struct WorksUploadCardTitle: View {
    let card: WorksUploadCard

    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system
    @Environment(\.locale) private var locale

    var body: some View {
        let text = NowContentText(
            card.title, sourceLanguage: card.sourceLanguage, translations: card.translations)
        Text(verbatim: text.resolved(for: contentLanguage, interfaceLocale: locale).text)
    }
}
