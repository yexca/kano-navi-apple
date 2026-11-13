import Foundation
import Testing

@testable import KanoNaviCore

struct LineBlogTests {
    private let client: APIClient

    init() throws {
        client = try ArchiveFixtures.client([
            "/api/lineblog": "lineblog-index",
            "/api/lineblog/posts/200": "lineblog-post",
            "/api/lineblog/posts/100": "lineblog-post-oldest",
            "/api/lineblog/posts/200/comments": "lineblog-comments",
            "/api/lineblog/posts/100/comments": "lineblog-comments-empty",
        ])
    }

    private func blocks() async throws -> [LineBlogBlock] {
        try await client.lineBlogPost(id: "200").post.blocks
    }

    @Test func decodesTheIndex() async throws {
        let index = try await client.lineBlog()
        #expect(index.originalBlogURL.absoluteString == "https://blog.example.com/kano/")
        #expect(index.posts.map(\.id) == ["300", "200"])
        #expect(
            index.posts[0].thumbnail?.url.absoluteString == "https://api.example.com/media/lineblog/thumb.jpg"
        )
        #expect(index.posts[1].thumbnail == nil)
        #expect(index.posts.map(\.commentCount) == [2, 0])
        #expect(index.months.map(\.month) == ["2019-03", "2018-12"])
        let title = try #require(
            index.posts[0].title.resolved(for: .zhHans, fallback: LocalizedText.japaneseOriginalFallback))
        #expect(title.locale == .ja)
    }

    @Test func decodesTheArticleAndItsNeighbours() async throws {
        let page = try await client.lineBlogPost(id: "200")
        #expect(page.previousID == "100")
        #expect(page.nextID == "300")
        #expect(page.post.url.absoluteString == "https://blog.example.com/kano/archives/200.html")
        #expect(page.post.archiveURL.host() == "archive.example.org")
        #expect(page.post.commentCount == 4)
        #expect(
            page.post.blocks.map(\.type) == [
                "paragraph", "paragraph", "quote", "rule", "video", "youtube", "youtube", "card", "card",
                "poll",
                "paragraph",
            ])
    }

    @Test func oldestArticleHasNoPreviousID() async throws {
        let page = try await client.lineBlogPost(id: "100")
        #expect(page.previousID == nil)
        #expect(page.nextID == "200")
    }

    @Test func articleCachedBeforeTheServiceCountedCommentsHasNoCount() async throws {
        let page = try await client.lineBlogPost(id: "100")
        #expect(page.post.commentCount == nil)
    }

    @Test func paragraphHasInlinesAndTranslations() async throws {
        guard case .paragraph(let paragraph) = try await blocks()[0] else {
            Issue.record("Expected a paragraph")
            return
        }
        #expect(paragraph.content.map(\.type) == ["text", "link", "image"])
        #expect(paragraph.content[0] == .text("こんにちは\n"))
        guard case .link(let link) = paragraph.content[1], case .image(let emoji) = paragraph.content[2]
        else {
            Issue.record("Expected a link and an image")
            return
        }
        #expect(link.articleID == "100")
        #expect(link.href.absoluteString == "https://blog.example.com/kano/archives/100.html")
        #expect(link.content == [.text("前の記事")])
        #expect(emoji.emoji)
        #expect(emoji.image?.url.absoluteString == "https://api.example.com/media/lineblog/emoji.png")
        #expect(emoji.sourceURL?.absoluteString == "https://img.example.com/emoji.png")
        #expect(paragraph.isFigureRow == false)

        let translations = try #require(paragraph.translations)
        #expect(translations[.zhHans] == [[.text("你好")]])
        #expect(translations[.en]?.count == 2)
        #expect(translations[.ja] == nil)
    }

    @Test func figureRowWithRecoveredAndMissingPictures() async throws {
        guard case .paragraph(let paragraph) = try await blocks()[1] else {
            Issue.record("Expected a paragraph")
            return
        }
        #expect(paragraph.isFigureRow)
        #expect(paragraph.translations?.isEmpty == true)
        let images: [LineBlogImage] = paragraph.content.compactMap {
            if case .image(let image) = $0 { return image }
            return nil
        }
        #expect(images.map(\.recovery) == [.standIn, .tweet, nil])
        #expect(images[0].alt == "Stage photo")
        #expect(images[0].href?.absoluteString == "https://photos.example.com/1")
        #expect(images[2].image == nil)
        #expect(images[2].remoteURL?.absoluteString == "https://img.example.com/missing/small")
        #expect(images[2].sourceURL == nil)
    }

    @Test func quoteRuleAndVideoWithoutSize() async throws {
        let blocks = try await blocks()
        #expect(blocks[2] == .quote([.text("引用")]))
        #expect(blocks[3] == .rule)
        guard case .video(let video) = blocks[4] else {
            Issue.record("Expected a video")
            return
        }
        #expect(video.url.absoluteString == "https://api.example.com/media/lineblog/clip.mp4")
        #expect(video.width == nil)
        #expect(video.height == nil)
        #expect(video.isVideo)
    }

    @Test func youtubeWithAndWithoutACopy() async throws {
        let blocks = try await blocks()
        guard case .youtube(let bare) = blocks[5], case .youtube(let copied) = blocks[6] else {
            Issue.record("Expected two YouTube blocks")
            return
        }
        #expect(bare.videoID == "vid_00001")
        #expect(bare.video == nil)
        #expect(bare.cover == nil)
        #expect(bare.archiveURL == nil)
        #expect(copied.video?.url.absoluteString == "https://api.example.com/media/lineblog/yt.mp4")
        #expect(copied.cover?.url.absoluteString == "https://api.example.com/media/lineblog/yt.jpg")
        #expect(copied.coverSourceURL?.absoluteString == "https://thumbs.example.com/vid_00002.jpg")
        #expect(copied.watchURL.absoluteString == "https://video.example.com/watch?v=vid_00002")
    }

    @Test func cardsWithAndWithoutAnArticle() async throws {
        let blocks = try await blocks()
        guard case .card(let article) = blocks[7], case .card(let shop) = blocks[8] else {
            Issue.record("Expected two cards")
            return
        }
        #expect(article.articleID == "100")
        #expect(article.description == nil)
        #expect(article.image?.image?.url.absoluteString == "https://api.example.com/media/lineblog/card.jpg")
        #expect(shop.articleID == nil)
        #expect(shop.image == nil)
        #expect(shop.description == "An item")
    }

    @Test func unknownBlockAndInlineTypesDoNotFailTheArticle() async throws {
        let blocks = try await blocks()
        #expect(blocks[9] == .unknown(type: "poll"))
        guard case .paragraph(let paragraph) = blocks[10] else {
            Issue.record("Expected a paragraph")
            return
        }
        #expect(paragraph.content == [.unknown(type: "sticker"), .text("after")])
    }

    @Test func blocksRoundTripThroughJSON() async throws {
        let page = try await client.lineBlogPost(id: "200")
        let data = try JSONEncoder.kanoNavi().encode(page)
        #expect(try JSONDecoder.kanoNavi().decode(LineBlogPostResponse.self, from: data) == page)
    }

    @Test func commentsWithEachRating() async throws {
        let comments = try await client.lineBlogComments(articleID: "200").comments
        #expect(comments.map(\.number) == [5, 3, 2, 1])
        #expect(comments.map(\.rating?.icon) == [.star, .face, nil, .unknown("heart")])
        #expect(comments[0].rating?.value == 5)
        #expect(comments[0].body == "一行目\n二行目")
        #expect(comments[0].posted == Date(timeIntervalSince1970: 1_472_991_660))
    }

    @Test func articleWithoutComments() async throws {
        let comments = try await client.lineBlogComments(articleID: "100")
        #expect(comments.comments.isEmpty)
    }
}
