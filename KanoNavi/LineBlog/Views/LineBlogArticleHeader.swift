import KanoNaviComponents
import SwiftUI

/// The top of an article: its title as written, the title's translation
/// when translations show, when it was published in Japan time, and the
/// note that translations are machine translations.
struct LineBlogArticleHeader: View {
    let title: LineBlogTitle
    let published: Date
    let showsTranslationNote: Bool

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let original = title.original {
                    Text(verbatim: original)
                } else {
                    Text(.LineBlog.untitled)
                }
            }
            .font(.title2.bold())
            .textSelection(.enabled)
            .accessibilityAddTraits(.isHeader)

            if let translated = title.translated {
                LineBlogTranslationMark {
                    Text(verbatim: translated)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }

            Text(verbatim: JSTTimeFormat.dateTime(published, locale: locale))
                .font(.subheadline)
                .monospacedDigit()
                .foregroundStyle(.secondary)

            if showsTranslationNote {
                Label {
                    Text(.LineBlog.translationNote)
                } icon: {
                    Image(systemName: "translate")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
