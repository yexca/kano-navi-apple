import SwiftUI

/// A link card: a card for another archived article opens it in the app, a
/// card for a web page opens outside. The archived capture of the linked
/// page is a link under the card.
struct LineBlogCardView: View {
    let card: LineBlogLinkCard

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch card.target {
            case .article(let id)?:
                NavigationLink(value: LineBlogDestination.article(id: id)) {
                    LineBlogCardLabel(card: card)
                }
                .buttonStyle(.plain)
            case .outside(let url)?:
                Link(destination: url) {
                    LineBlogCardLabel(card: card)
                }
                .buttonStyle(.plain)
            case nil:
                LineBlogCardLabel(card: card)
            }
            if let url = card.archiveURL {
                LineBlogProvenanceLink(title: .LineBlog.archivedCapture, url: url)
            }
        }
    }
}
