import KanoNaviCore
import SwiftUI

/// A button to the older or the newer article, with that article's title
/// when the article list is at hand.
struct LineBlogNeighborButton: View {
    let direction: LineBlogNeighborDirection
    let title: LocalizedText?
    let action: () -> Void

    @ContentLocaleSetting private var contentLocale

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Label {
                    Text(direction.label)
                } icon: {
                    Image(systemName: direction.systemImage)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)
                if let title, let text = LineBlogTitle.listTitle(title, locale: contentLocale) {
                    Text(verbatim: text)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .multilineTextAlignment(.leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.fill.quaternary, in: .rect(cornerRadius: 12))
            .contentShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
