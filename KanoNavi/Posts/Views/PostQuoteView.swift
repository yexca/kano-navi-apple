import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The status a post quotes, nested in the post: its author, time, text in
/// the content language and images, with a button to open it. An unavailable
/// quote says so and still links to where it was.
struct PostQuoteView: View {
    let quote: PostQuoteCard

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if quote.isUnavailable {
                Label {
                    Text(.Posts.quoteUnavailable)
                } icon: {
                    Image(systemName: "text.bubble.badge.clock")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            } else {
                PostQuoteHeader(quote: quote)
                if let text = quote.text {
                    NowTitle(text: text, switchable: true)
                        .font(.subheadline)
                }
                PostImageGrid(images: quote.images, limit: 2)
            }
            Button(action: open) {
                Label {
                    Text(quote.isBilibili ? .Posts.openQuoteBilibili : .Posts.openQuote)
                } icon: {
                    Image(systemName: "arrow.up.right.square")
                }
            }
            .buttonStyle(.compactLink)
            .font(.subheadline)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.quaternary, in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.separator)
        }
    }

    private func open() {
        openURL(quote.url)
    }
}
