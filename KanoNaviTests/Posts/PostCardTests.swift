import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct PostCardTests {
    @Test func xPostIsNamedByItsHandle() throws {
        let card = try PostFixtures.card(PostFixtures.json(id: "1", handle: "kano_example"))

        #expect(card.account == .x(handle: "kano_example"))
        #expect(card.isBilibili == false)
        #expect(card.isPromoted == false)
    }

    @Test func bilibiliDynamicIsNamedByItsPlatform() throws {
        let card = try PostFixtures.card(
            PostFixtures.json(id: "bilibili-1", source: "bilibili", handle: "316381099"))

        #expect(card.account == .bilibili)
        #expect(card.isBilibili)
    }

    @Test func promotedPostIsTheAgencys() throws {
        let card = try PostFixtures.card(PostFixtures.json(id: "1", handle: "agency", promoted: true))

        #expect(card.isPromoted)
    }

    @Test func emptyTextIsLeftOut() throws {
        let card = try PostFixtures.card(PostFixtures.json(id: "1", source: "bilibili", text: ""))

        #expect(card.text == nil)
    }

    @Test func onlyReadyMediaAreShown() throws {
        let card = try PostFixtures.card(
            PostFixtures.json(
                id: "1",
                media: [
                    PostFixtures.media("a"), PostFixtures.media("b", status: "pending"),
                    PostFixtures.media("c", status: "failed"), PostFixtures.media("d"),
                ]))

        #expect(card.images.map(\.id) == ["a", "d"])
        #expect(card.images.first?.aspectRatio == 1.5)
    }

    @Test func olderSingleMediaURLIsShownWhenReady() throws {
        let ready = try PostFixtures.card(
            PostFixtures.json(id: "1", mediaURL: "https://example.com/media/one", mediaStatus: "ready"))
        let pending = try PostFixtures.card(
            PostFixtures.json(id: "2", mediaURL: "https://example.com/media/two", mediaStatus: "pending"))

        #expect(ready.images.map(\.url.absoluteString) == ["https://example.com/media/one"])
        #expect(pending.images.isEmpty)
    }

    @Test func quoteShowsItsAuthorTextAndReadyImages() throws {
        let card = try PostFixtures.card(
            PostFixtures.json(
                id: "1",
                quote: PostFixtures.quote(
                    name: "Quoted Name",
                    media: [PostFixtures.media("q1"), PostFixtures.media("q2", status: "pending")])))

        let quote = try #require(card.quote)
        #expect(quote.isUnavailable == false)
        #expect(quote.authorName == "Quoted Name")
        #expect(quote.authorHandle == "@quoted")
        #expect(quote.text?.original == "Quoted")
        #expect(quote.images.map(\.id) == ["q1"])
    }

    @Test func quoteWithoutANameShowsItsHandle() throws {
        let card = try PostFixtures.card(PostFixtures.json(id: "1", quote: PostFixtures.quote()))

        #expect(card.quote?.authorName == "@quoted")
        #expect(card.quote?.authorHandle == nil)
    }

    @Test func unavailableQuoteKeepsOnlyItsLink() throws {
        let card = try PostFixtures.card(
            PostFixtures.json(
                id: "1",
                quote: PostFixtures.quote(
                    unavailable: true, handle: nil, text: nil, media: [PostFixtures.media("q")])))

        let quote = try #require(card.quote)
        #expect(quote.isUnavailable)
        #expect(quote.text == nil)
        #expect(quote.images.isEmpty)
        #expect(quote.url.absoluteString == "https://example.com/post/Q1")
    }

    @Test func forwardedDynamicsAuthorIsNeverNamedByMid() throws {
        let card = try PostFixtures.card(
            PostFixtures.json(
                id: "bilibili-1", source: "bilibili", quote: PostFixtures.quote(handle: "12345")))

        #expect(card.quote?.isBilibili == true)
        #expect(card.quote?.authorName == nil)
        #expect(card.quote?.authorHandle == nil)
    }
}
