import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// Blocks and inlines become what the reader lays out.
struct LineBlogArticleLayoutTests {
    typealias Fixtures = LineBlogFixtures

    // MARK: Running text

    @Test func neighbouringTextIsOneRunAndKeepsItsLineBreaks() throws {
        let layout = try Fixtures.layout(Fixtures.paragraph(Fixtures.text("一行目\n"), Fixtures.text("二行目")))

        #expect(try text(layout, block: 0).runs == [.text("一行目\n二行目", link: nil)])
    }

    @Test func linkCoversItsContentAndOnlyThat() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(
                Fixtures.text("前 "), Fixtures.link("https://example.com/page", Fixtures.text("リンク")),
                Fixtures.text(" 後")))
        let target = LineBlogLinkTarget.outside(URL(string: "https://example.com/page")!)

        #expect(
            try text(layout, block: 0).runs
                == [.text("前 ", link: nil), .text("リンク", link: target), .text(" 後", link: nil)])
    }

    @Test func linkToAnArchivedArticleOpensItInTheApp() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(
                Fixtures.link(
                    "https://blog.example.com/archives/2002.html", articleID: "2002", Fixtures.text("前回"))))

        #expect(try text(layout, block: 0).runs == [.text("前回", link: .article(id: "2002"))])
    }

    @Test func innermostLinkWins() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(
                Fixtures.link(
                    "https://example.com/outer", Fixtures.text("外"),
                    Fixtures.link("https://example.com/inner", Fixtures.text("内")))))

        #expect(
            try text(layout, block: 0).runs == [
                .text("外", link: .outside(URL(string: "https://example.com/outer")!)),
                .text("内", link: .outside(URL(string: "https://example.com/inner")!)),
            ])
    }

    @Test func textOfALinkThatIsNotAWebAddressIsPlainText() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(Fixtures.text("前"), Fixtures.link("javascript:void(0)", Fixtures.text("押す"))))

        #expect(try text(layout, block: 0).runs == [.text("前押す", link: nil)])
    }

    @Test func pictographsStayInTheTextInReadingOrder() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(
                Fixtures.text("楽しい"), Fixtures.pictograph("smile.png", alt: "笑顔"), Fixtures.text("ね"),
                Fixtures.pictograph("star.png")))

        #expect(
            try text(layout, block: 0).runs == [
                .text("楽しい", link: nil),
                .pictograph(
                    LineBlogPictograph(
                        source: Fixtures.source("smile.png", width: 20, height: 20), alt: "笑顔"), link: nil),
                .text("ね", link: nil),
                .pictograph(
                    LineBlogPictograph(source: Fixtures.source("star.png", width: 20, height: 20), alt: nil),
                    link: nil),
            ])
        #expect(layout.pictures.isEmpty, "a pictograph never opens in the viewer")
    }

    @Test func aLongParagraphWithManyPictographsIsOneText() throws {
        var content: [Fixtures.JSON] = []
        for index in 0..<12 {
            content.append(Fixtures.text(String(repeating: "あ", count: 30)))
            content.append(Fixtures.pictograph("p\(index % 3).png"))
        }
        let layout = try Fixtures.layout(["type": "paragraph", "content": content, "translations": NSNull()])

        let segments = try paragraph(layout, block: 0).segments
        #expect(segments.count == 1)
        #expect(try text(layout, block: 0).runs.count == 24)
        #expect(layout.pictographs.count == 3, "each pictograph file is loaded once")
    }

    @Test func pictographTheArchiveNeverCapturedKeepsItsDescription() throws {
        let layout = try Fixtures.layout(Fixtures.paragraph(Fixtures.pictograph(nil, alt: "音符")))

        #expect(
            try text(layout, block: 0).runs
                == [.pictograph(LineBlogPictograph(source: nil, alt: "音符"), link: nil)])
        #expect(layout.pictographs.isEmpty)
    }

    // MARK: Figures

    @Test func paragraphOfOnlyPicturesIsOneRowOfFigures() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(Fixtures.image("a.jpg", alt: "一枚目"), Fixtures.image("b.jpg")))

        let segments = try paragraph(layout, block: 0).segments
        #expect(segments == [.figures([.picture(layout.pictures[0]), .picture(layout.pictures[1])])])
        #expect(layout.pictures.map(\.alt) == ["一枚目", nil])
    }

    @Test func picturesBetweenTextSplitTheParagraphInReadingOrder() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(
                Fixtures.text("写真です\n"), Fixtures.image("a.jpg"), Fixtures.text(" \n"),
                Fixtures.image("b.jpg"),
                Fixtures.text("\nおわり")))

        #expect(
            try paragraph(layout, block: 0).segments == [
                .text(LineBlogRichText(runs: [.text("写真です", link: nil)])),
                .figures([.picture(layout.pictures[0]), .picture(layout.pictures[1])]),
                .text(LineBlogRichText(runs: [.text("おわり", link: nil)])),
            ])
    }

    @Test func pictureTheArchiveNeverCapturedKeepsItsOriginalAddress() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(
                Fixtures.image(nil, alt: "告知画像", remoteURL: "https://img.example.com/lost.jpg")))

        #expect(
            try paragraph(layout, block: 0).segments == [
                .figures([
                    .uncaptured(
                        LineBlogUncapturedPicture(
                            alt: "告知画像", remoteURL: URL(string: "https://img.example.com/lost.jpg")))
                ])
            ])
        #expect(layout.pictures.isEmpty)
    }

    @Test func pictureKeepsItsRecoveryMarkAndProvenance() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(
                Fixtures.image(
                    "a.jpg", href: "https://example.com/full", sourceURL: "https://archive.example.com/a.jpg",
                    recovery: "stand-in"),
                Fixtures.image("b.jpg", recovery: "tweet"), Fixtures.image("c.jpg", recovery: "later-code")))

        #expect(layout.pictures.map(\.recovery) == [.standIn, .tweet, .unknown("later-code")])
        #expect(layout.pictures[0].sourceURL == URL(string: "https://archive.example.com/a.jpg"))
        #expect(layout.pictures[0].link == URL(string: "https://example.com/full"))
    }

    @Test func pictureInsideALinkLeadsWhereTheLinkDid() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(Fixtures.link("https://example.com/shop", Fixtures.image("a.jpg"))))

        #expect(layout.pictures.first?.link == URL(string: "https://example.com/shop"))
    }

    // MARK: Viewer pictures

    @Test func viewerPicturesAreTheArchivedPicturesInReadingOrder() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(Fixtures.text("本文"), Fixtures.pictograph("smile.png")),
            Fixtures.paragraph(Fixtures.image("first.jpg")),
            Fixtures.paragraph(Fixtures.image(nil, remoteURL: "https://img.example.com/lost.jpg")),
            Fixtures.card(image: "card.jpg"), Fixtures.youtube(cover: "cover.jpg"),
            Fixtures.quote(Fixtures.image("second.jpg")),
            Fixtures.paragraph(Fixtures.image("third.jpg"), Fixtures.image("fourth.jpg")))

        #expect(
            layout.pictures.map(\.source.url.lastPathComponent)
                == ["first.jpg", "second.jpg", "third.jpg", "fourth.jpg"])
        #expect(layout.pictures.map(\.id) == [0, 1, 2, 3])
    }

    // MARK: Blocks

    @Test func unknownBlocksAndInlinesAreSkippedAndTheRestStays() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(Fixtures.text("はじめ")), ["type": "poll", "question": "?"],
            Fixtures.paragraph(Fixtures.text("前"), ["type": "ruby", "base": "漢字"], Fixtures.text("後")),
            Fixtures.paragraph(["type": "ruby", "base": "漢字"]), Fixtures.rule)

        #expect(layout.blocks.map(\.id) == [0, 2, 4], "a block keeps its position in the article as its ID")
        #expect(try text(layout, block: 1).runs == [.text("前後", link: nil)])
        #expect(layout.blocks.last?.content == .rule)
    }

    @Test func paragraphWithNothingToReadIsDropped() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(Fixtures.text(" \n")), Fixtures.paragraph(),
            Fixtures.paragraph(Fixtures.text("本文")))

        #expect(layout.blocks.map(\.id) == [2])
    }

    @Test func quoteIsLaidOutLikeAParagraph() throws {
        let layout = try Fixtures.layout(Fixtures.quote(Fixtures.text("引用です"), Fixtures.image("a.jpg")))

        #expect(
            layout.blocks.first?.content
                == .quote([
                    .text(LineBlogRichText(runs: [.text("引用です", link: nil)])),
                    .figures([.picture(layout.pictures[0])]),
                ]))
    }

    @Test func youtubeBlockWithACopyPlaysTheServiceFile() throws {
        let layout = try Fixtures.layout(Fixtures.youtube(id: "abc", video: "copy.mp4", cover: "cover.jpg"))

        #expect(
            layout.blocks.first?.content
                == .video(
                    LineBlogVideoEmbed(
                        file: URL(string: Fixtures.media + "copy.mp4"),
                        cover: Fixtures.source("cover.jpg", width: 480, height: 360),
                        watchURL: URL(string: "https://video.example.com/watch?v=abc"),
                        archiveURL: URL(string: "https://archive.example.com/watch?v=abc"))))
    }

    @Test func youtubeBlockWithoutACopyHasOnlyItsCoverAndWatchPage() throws {
        let layout = try Fixtures.layout(Fixtures.youtube(id: "abc", cover: "cover.jpg"))

        guard case .video(let video)? = layout.blocks.first?.content else {
            Issue.record("expected a video block")
            return
        }
        #expect(video.file == nil)
        #expect(video.cover != nil)
        #expect(video.watchURL == URL(string: "https://video.example.com/watch?v=abc"))
    }

    @Test func videoBlockPlaysItsFileWithoutACoverOrWatchPage() throws {
        let layout = try Fixtures.layout(Fixtures.video("clip.mp4"))

        #expect(
            layout.blocks.first?.content
                == .video(
                    LineBlogVideoEmbed(
                        file: URL(string: Fixtures.media + "clip.mp4"), cover: nil, watchURL: nil,
                        archiveURL: nil)))
    }

    @Test func cardLeadsToAnArticleInTheAppOrToAPageOutside() throws {
        let layout = try Fixtures.layout(
            Fixtures.card(
                title: "前の記事", url: "https://blog.example.com/archives/2002.html", articleID: "2002"),
            Fixtures.card(
                title: "お店", url: "https://shop.example.com/item", description: "商品の説明", image: "card.jpg"),
            Fixtures.card(title: "同じ", description: "同じ"), Fixtures.card(title: "壊れた", url: "about:blank"))
        let cards = layout.blocks.compactMap { block in
            if case .card(let card) = block.content { card } else { nil }
        }

        #expect(
            cards.map(\.target) == [
                .article(id: "2002"), .outside(URL(string: "https://shop.example.com/item")!),
                .outside(URL(string: "https://shop.example.com/item")!), nil,
            ])
        #expect(cards.map(\.host) == [nil, "shop.example.com", "shop.example.com", nil])
        #expect(
            cards.map(\.description) == [nil, "商品の説明", nil, nil], "a summary repeating the title is left out")
        #expect(cards[1].image == Fixtures.source("card.jpg", width: 200, height: 200))
        #expect(cards[0].archiveURL == URL(string: "https://archive.example.com/card"))
    }

    // MARK: Translations

    @Test func translationsAreTextOfTheirOwnLanguage() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(
                Fixtures.text("こんにちは"), Fixtures.pictograph("smile.png"),
                chinese: [[Fixtures.text("你好"), Fixtures.pictograph("smile.png")]],
                english: [
                    [
                        Fixtures.text("Hello "),
                        Fixtures.link("https://example.com/en", Fixtures.text("there")),
                    ],
                    [Fixtures.text("Second paragraph")],
                ]))
        let paragraph = try paragraph(layout, block: 0)

        #expect(paragraph.chinese.map(\.plainText) == ["你好"])
        #expect(paragraph.english.map(\.plainText) == ["Hello there", "Second paragraph"])
        #expect(
            paragraph.english.first?.runs.last
                == .text("there", link: .outside(URL(string: "https://example.com/en")!)))
        #expect(layout.pictographs.count == 1, "a pictograph repeated in a translation is loaded once")
    }

    @Test func translationLeavesOutPicturesAndEmptyParagraphs() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(
                Fixtures.image("a.jpg"), Fixtures.text("写真"),
                chinese: [[Fixtures.text(" ")]],
                english: [[Fixtures.image("a.jpg"), Fixtures.text("A photo")]]))
        let paragraph = try paragraph(layout, block: 0)

        #expect(paragraph.chinese.isEmpty)
        #expect(paragraph.english.map(\.plainText) == ["A photo"])
        #expect(
            layout.pictures.count == 1, "a translation's copy of a picture is not a second viewer picture")
    }

    @Test func layoutKnowsWhichLanguagesHaveTranslations() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(Fixtures.text("原文"), english: [[Fixtures.text("Original")]]),
            Fixtures.paragraph(Fixtures.text("署名")))

        #expect(layout.hasTranslation(in: .en))
        #expect(layout.hasTranslation(in: .zhHans) == false)
        #expect(layout.hasTranslation(in: .ja) == false)
    }

    // MARK: Helpers

    private func paragraph(_ layout: LineBlogArticleLayout, block index: Int) throws
        -> LineBlogReaderParagraph
    {
        let block = try #require(layout.blocks.indices.contains(index) ? layout.blocks[index] : nil)
        guard case .paragraph(let paragraph) = block.content else {
            throw FixtureError.notAParagraph
        }
        return paragraph
    }

    /// The text of a paragraph that is text alone.
    private func text(_ layout: LineBlogArticleLayout, block index: Int) throws -> LineBlogRichText {
        let segments = try paragraph(layout, block: index).segments
        guard segments.count == 1, case .text(let text)? = segments.first else {
            throw FixtureError.notPlainText
        }
        return text
    }

    private enum FixtureError: Error {
        case notAParagraph
        case notPlainText
    }
}
