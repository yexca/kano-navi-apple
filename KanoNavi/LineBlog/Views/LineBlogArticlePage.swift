import KanoNaviCore
import SwiftUI

/// One article: loading, the article itself, the not-found state for a
/// number the archive does not have, or the reason it could not be read.
struct LineBlogArticlePage: View {
    let client: APIClient
    let index: DocumentModel<LineBlogIndexRequest>
    let articleID: String
    /// Replaces the article on screen with a neighbour.
    let show: (String) -> Void

    @State private var model: DocumentModel<LineBlogPostRequest>
    @State private var showsTranslations = true
    /// The article a link in the text asked for.
    @State private var linkedArticleID: String?
    @ContentLocaleSetting private var contentLocale
    @Environment(\.locale) private var locale

    init(
        client: APIClient, index: DocumentModel<LineBlogIndexRequest>, articleID: String,
        show: @escaping (String) -> Void
    ) {
        self.client = client
        self.index = index
        self.articleID = articleID
        self.show = show
        _model = State(
            initialValue: DocumentModel(client: client, request: LineBlogPostRequest(id: articleID)))
    }

    var body: some View {
        ZStack {
            if let response = model.value {
                let layout = LineBlogArticleLayout(article: response.post)
                LineBlogArticleContent(
                    response: response, layout: layout,
                    translation: LineBlogTranslationDisplay.locale(
                        content: contentLocale, isOn: showsTranslations),
                    summaries: index.value?.posts ?? [], notice: model.notice, reload: model.reload,
                    show: show
                )
                .toolbar {
                    if contentLocale != .ja, layout.hasTranslation(in: contentLocale) {
                        ToolbarItem(placement: .primaryAction) {
                            Toggle(isOn: $showsTranslations) {
                                Label {
                                    Text(.LineBlog.translationToggle)
                                } icon: {
                                    Image(systemName: "translate")
                                }
                            }
                        }
                    }
                }
                .navigationTitle(Text(verbatim: dateTitle(response.post.published)))
            } else if LineBlogArticleFailure.isNotFound(model.failure) {
                LineBlogNotFoundView()
            } else {
                DocumentUnavailableView(reason: model.failureReason, reload: model.reload)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await model.load()
        }
        .environment(\.openURL, OpenURLAction(handler: open))
        .navigationDestination(item: $linkedArticleID) { id in
            LineBlogArticleScreen(client: client, index: index, articleID: id)
        }
    }

    /// Routes a tapped link: an archived article is pushed here, a web page
    /// goes to the system, anything else is dropped.
    private func open(_ url: URL) -> OpenURLAction.Result {
        switch LineBlogLinkTarget(opened: url) {
        case .article(let id)?:
            linkedArticleID = id
            return .handled
        case .outside?:
            return .systemAction
        case nil:
            return .discarded
        }
    }

    /// The Japan date the article was published on, for the bar.
    private func dateTitle(_ published: Date) -> String {
        published.formatted(
            Date.FormatStyle(
                date: .abbreviated, time: .omitted, locale: locale,
                calendar: Calendar(identifier: .gregorian),
                timeZone: JapanDate.timeZone))
    }
}
