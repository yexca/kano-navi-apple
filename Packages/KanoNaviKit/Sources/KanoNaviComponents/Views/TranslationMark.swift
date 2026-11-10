import KanoNaviCore
import SwiftUI

/// Marks content text shown in translation and names where the translation
/// came from: manual, platform or machine.
///
/// It only labels; a screen that can switch to the original places its own
/// control beside it. Safe in widgets.
public struct TranslationMark: View {
    private let origin: TranslationOrigin?

    /// Creates a mark for a translation's origin, usually
    /// `ResolvedContentText.origin`.
    public init(origin: TranslationOrigin?) {
        self.origin = origin
    }

    public var body: some View {
        Label {
            Text(DisplayCodeLabels.translationOrigin(origin))
        } icon: {
            Image(systemName: "translate")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    VStack(alignment: .leading) {
        TranslationMark(origin: .manual)
        TranslationMark(origin: .machine)
    }
}
