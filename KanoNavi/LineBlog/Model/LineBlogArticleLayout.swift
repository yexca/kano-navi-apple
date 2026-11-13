import Foundation
import KanoNaviCore

/// An article turned into what the reader lays out: its blocks in reading
/// order, the pictures the image viewer pages through and the pictographs to
/// load before the text is drawn.
///
/// - A paragraph is running text, with pictographs inside it, and rows of
///   pictures where pictures stand between the text.
/// - A block or inline of a type this app does not know is skipped, and so is
///   a paragraph with nothing left to show; the rest of the article stays.
/// - Pictographs and pictures the archive never captured are not viewer
///   pictures; link card images and video covers are not either.
nonisolated struct LineBlogArticleLayout: Hashable, Sendable {
    let blocks: [LineBlogReaderBlock]
    /// Every archived picture of the article, in reading order.
    let pictures: [LineBlogPicture]
    /// The files of the pictographs in the text and its translations, each
    /// once.
    let pictographs: [MediaImageSource]

    init(article: LineBlogArticle) {
        var builder = Builder()
        blocks = article.blocks.enumerated().compactMap { index, block in
            builder.content(of: block).map { LineBlogReaderBlock(id: index, content: $0) }
        }
        pictures = builder.pictures
        pictographs = builder.pictographs
    }

    /// Whether any paragraph has a translation shown for `locale`.
    func hasTranslation(in locale: ContentLocale) -> Bool {
        blocks.contains { block in
            if case .paragraph(let paragraph) = block.content {
                return paragraph.translation(in: locale).isEmpty == false
            }
            return false
        }
    }

    /// Walks the article once, numbering its viewer pictures and collecting
    /// its pictographs on the way.
    private struct Builder {
        var pictures: [LineBlogPicture] = []
        var pictographs: [MediaImageSource] = []
        private var seenPictographs: Set<MediaImageSource> = []

        mutating func content(of block: LineBlogBlock) -> LineBlogReaderBlock.Content? {
            switch block {
            case .paragraph(let paragraph):
                let segments = segments(of: paragraph.content)
                guard segments.isEmpty == false else { return nil }
                return .paragraph(
                    LineBlogReaderParagraph(
                        segments: segments,
                        chinese: translation(paragraph.translations?.zhCN),
                        english: translation(paragraph.translations?.en)))
            case .quote(let content):
                let segments = segments(of: content)
                return segments.isEmpty ? nil : .quote(segments)
            case .rule:
                return .rule
            case .video(let media):
                return .video(LineBlogVideoEmbed(file: media.url, cover: nil, watchURL: nil, archiveURL: nil))
            case .youtube(let youtube):
                return .video(
                    LineBlogVideoEmbed(
                        file: youtube.video?.url, cover: youtube.cover.map(Self.source),
                        watchURL: LineBlogLinkTarget.outsideURL(youtube.watchURL),
                        archiveURL: LineBlogLinkTarget.outsideURL(youtube.archiveURL)))
            case .card(let card):
                return .card(Self.card(card))
            case .unknown:
                return nil
            }
        }

        /// The translated paragraphs of one language. A translation is text:
        /// its pictures, which the original paragraph already shows, are
        /// left out, and a paragraph without text is dropped.
        private mutating func translation(_ paragraphs: [[LineBlogInline]]?) -> [LineBlogRichText] {
            (paragraphs ?? []).compactMap { inlines in
                var text = LineBlogRichText()
                for case .run(let run) in flattened(inlines, keepsFigures: false) {
                    text.append(run)
                }
                let trimmed = text.trimmed()
                return trimmed.isBlank ? nil : trimmed
            }
        }

        /// Text and rows of pictures in reading order. Pictures with nothing
        /// but spaces between them share a row.
        private mutating func segments(of inlines: [LineBlogInline]) -> [LineBlogSegment] {
            var segments: [LineBlogSegment] = []
            var text = LineBlogRichText()
            var figures: [LineBlogFigure] = []

            for item in flattened(inlines) {
                switch item {
                case .run(let run):
                    text.append(run)
                case .figure(let figure):
                    if text.isBlank == false {
                        if figures.isEmpty == false {
                            segments.append(.figures(figures))
                            figures = []
                        }
                        segments.append(.text(text.trimmed()))
                    }
                    text = LineBlogRichText()
                    figures.append(figure)
                }
            }
            if figures.isEmpty == false {
                segments.append(.figures(figures))
            }
            if text.isBlank == false {
                segments.append(.text(text.trimmed()))
            }
            return segments
        }

        private enum Item {
            case run(LineBlogTextRun)
            case figure(LineBlogFigure)
        }

        /// The inlines in reading order with links resolved onto what they
        /// surround; the innermost link wins. Without `keepsFigures`,
        /// pictures other than pictographs are left out and not counted as
        /// viewer pictures.
        private mutating func flattened(
            _ inlines: [LineBlogInline], link: LineBlogLinkTarget? = nil, keepsFigures: Bool = true
        ) -> [Item] {
            var items: [Item] = []
            for inline in inlines {
                switch inline {
                case .text(let text):
                    items.append(.run(.text(text, link: link)))
                case .link(let inner):
                    let target = LineBlogLinkTarget(href: inner.href, articleID: inner.articleID) ?? link
                    items += flattened(inner.content, link: target, keepsFigures: keepsFigures)
                case .image(let image) where image.emoji:
                    let source = image.image.map(Self.source)
                    if let source, seenPictographs.insert(source).inserted {
                        pictographs.append(source)
                    }
                    items.append(
                        .run(.pictograph(LineBlogPictograph(source: source, alt: image.alt), link: link)))
                case .image(let image):
                    if keepsFigures {
                        items.append(.figure(figure(image, link: link)))
                    }
                case .unknown:
                    break
                }
            }
            return items
        }

        private mutating func figure(_ image: LineBlogImage, link: LineBlogLinkTarget?) -> LineBlogFigure {
            guard let media = image.image else {
                return .uncaptured(
                    LineBlogUncapturedPicture(
                        alt: image.alt, remoteURL: LineBlogLinkTarget.outsideURL(image.remoteURL)))
            }
            var page = LineBlogLinkTarget.outsideURL(image.href)
            if page == nil, case .outside(let url)? = link {
                page = url
            }
            let picture = LineBlogPicture(
                id: pictures.count, source: Self.source(media), alt: image.alt, recovery: image.recovery,
                sourceURL: LineBlogLinkTarget.outsideURL(image.sourceURL), link: page)
            pictures.append(picture)
            return .picture(picture)
        }

        private static func card(_ card: LineBlogCard) -> LineBlogLinkCard {
            let target = LineBlogLinkTarget(href: card.url, articleID: card.articleID)
            var host: String?
            if case .outside(let url)? = target {
                host = url.host()
            }
            let description = card.description.flatMap { text in
                text.isEmpty || text == card.title ? nil : text
            }
            return LineBlogLinkCard(
                title: card.title, description: description,
                image: card.image?.image.map(Self.source), target: target, host: host,
                archiveURL: LineBlogLinkTarget.outsideURL(card.archiveURL))
        }

        private static func source(_ media: LineBlogMedia) -> MediaImageSource {
            MediaImageSource(url: media.url, width: media.width, height: media.height)
        }
    }
}
