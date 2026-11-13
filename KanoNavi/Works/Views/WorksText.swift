import KanoNaviCore
import SwiftUI

/// Wording the Works collection gives in each language, shown in the
/// content language; a missing language falls back to English, then
/// Japanese, then Chinese.
struct WorksText: View {
    let text: LocalizedText

    @ContentLocaleSetting private var contentLocale

    init(_ text: LocalizedText) {
        self.text = text
    }

    var body: some View {
        Text(verbatim: text.resolved(for: contentLocale)?.text ?? "")
    }
}
