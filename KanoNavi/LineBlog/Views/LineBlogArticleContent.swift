import KanoNaviCore
import SwiftUI

/// The article laid out for reading: its title and date, its blocks, then
/// the comments, the neighbouring articles and where it was recovered
/// from. Pictures open in the image viewer, which pages through all of the
/// article's pictures.
struct LineBlogArticleContent: View {
    let response: LineBlogPostResponse
    let layout: LineBlogArticleLayout
    /// The language whose translations show, or `nil` for none.
    let translation: ContentLocale?
    /// The archive's article list, for the comment count and the
    /// neighbours' titles; empty when it has not been read.
    let summaries: [LineBlogPostSummary]
    let notice: DocumentNotice?
    let reload: () async -> Void
    let show: (String) -> Void

    @State private var pictographs = LineBlogPictographStore()
    @State private var openedPicture: LineBlogPicture?
    @Environment(\.mediaImageLoader) private var loader
    @Environment(\.displayScale) private var displayScale

    /// The widest a line of text gets, so long lines stay readable.
    private static let readingWidth: CGFloat = 640

    var body: some View {
        ScrollView {
            // Not a lazy stack: an article is a few dozen blocks of very
            // different heights (a line of text, a tall photo), which a
            // lazy stack has to estimate and could fail to settle on. Laid
            // out whole, every block has its real height from the start;
            // pictures still load only once they scroll into view.
            VStack(alignment: .leading, spacing: 14) {
                if let notice {
                    DocumentStatusNotice(notice: notice, reload: reload)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.fill.quaternary, in: .rect(cornerRadius: 12))
                }

                LineBlogArticleHeader(
                    title: LineBlogTitle(response.post.title, translation: translation),
                    published: response.post.published, showsTranslationNote: translation != nil
                )
                .padding(.bottom, 6)

                ForEach(layout.blocks) { block in
                    LineBlogBlockView(
                        block: block, translation: translation, pictographs: pictographs, open: open)
                }

                LineBlogArticleFooter(response: response, summaries: summaries, show: show)
                    .padding(.top, 18)
            }
            .frame(maxWidth: Self.readingWidth, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .refreshable {
            await reload()
        }
        .task(id: layout.pictographs) {
            await pictographs.load(layout.pictographs, with: loader, displayScale: displayScale)
        }
        .mediaViewer(item: $openedPicture, in: layout.pictures) { picture in
            picture.source
        } label: { picture in
            LineBlogPictureLabel.text(for: picture)
        } caption: { picture in
            LineBlogPictureCaption(picture: picture)
        }
    }

    private func open(_ picture: LineBlogPicture) {
        openedPicture = picture
    }
}

#if DEBUG
    #Preview("English translations") {
        if let response = LineBlogPreviewData.response {
            NavigationStack {
                LineBlogArticleContent(
                    response: response, layout: LineBlogArticleLayout(article: response.post),
                    translation: .en,
                    summaries: LineBlogPreviewData.summaries, notice: nil, reload: {}, show: { _ in })
            }
            .environment(\.mediaImageLoader, LineBlogPreviewData.loader)
        }
    }

    #Preview("Saved copy, no translations") {
        if let response = LineBlogPreviewData.response {
            NavigationStack {
                LineBlogArticleContent(
                    response: response, layout: LineBlogArticleLayout(article: response.post),
                    translation: nil,
                    summaries: [], notice: .saved(fetchedAt: Date(timeIntervalSince1970: 1_794_000_000)),
                    reload: {}, show: { _ in })
            }
            .environment(\.mediaImageLoader, LineBlogPreviewData.loader)
        }
    }
#endif
