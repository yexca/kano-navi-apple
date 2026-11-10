import KanoNaviCore
import SwiftUI

/// A title or text from the API in the content language. A translation shows
/// a small mark naming its origin; when `switchable`, the mark switches to
/// the original wording in place.
struct NowTitle: View {
    let text: NowContentText
    var switchable = false

    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system
    @Environment(\.locale) private var locale
    @State private var showsOriginal = false

    var body: some View {
        let resolved = text.resolved(for: contentLanguage, interfaceLocale: locale)
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: showsOriginal ? resolved.original : resolved.text)
                .fixedSize(horizontal: false, vertical: true)

            if resolved.isTranslation {
                mark(for: resolved)
            }
        }
    }

    private func mark(for resolved: ResolvedContentText) -> some View {
        NowFlowLayout(spacing: 8) {
            Label {
                Text(DisplayCodeLabels.translationOrigin(resolved.origin))
            } icon: {
                Image(systemName: "character.bubble")
            }
            .foregroundStyle(.secondary)
            .labelStyle(NowCompactLabelStyle())

            if switchable {
                Button(showsOriginal ? .Now.showTranslation : .Now.showOriginal) {
                    showsOriginal.toggle()
                }
                .buttonStyle(.borderless)
            }
        }
        .font(.caption)
    }
}
