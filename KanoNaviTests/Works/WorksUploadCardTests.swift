import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// The uploads the Works entry shows as cards, and the page a card opens.
struct WorksUploadCardTests {
    @Test func newerVideosLeadThenTheCollectionNewestFirst() throws {
        let list = try WorksFixtures.uploadList([
            WorksFixtures.upload(id: "a", date: "2019-01-01", youtube: ["a1"]),
            WorksFixtures.upload(id: "b", date: "2021-05-05", youtube: ["b1"]),
            WorksFixtures.upload(id: "c", date: "2021-05-05", youtube: ["c1"]),
        ])
        let stored = try WorksFixtures.stored(
            uploads: ["b": WorksFixtures.state(cover: WorksFixtures.cover("b"))],
            recent: [WorksFixtures.recent(id: "n2"), WorksFixtures.recent(id: "n1")])

        let cards = WorksUploadCard.newestFirst(list: list, stored: stored)

        #expect(
            cards.map(\.id) == [
                "recent.n2", "recent.n1", "collection.c", "collection.b", "collection.a",
            ])
        #expect(cards.first { $0.sourceID == "b" }?.cover?.url.lastPathComponent == "b")
    }

    @Test func eitherReadAloneStillGivesItsCards() throws {
        let list = try WorksFixtures.uploadList([WorksFixtures.upload(id: "a", date: "2019-01-01")])
        let stored = try WorksFixtures.stored(recent: [WorksFixtures.recent(id: "n1")])

        #expect(WorksUploadCard.newestFirst(list: list, stored: nil).map(\.id) == ["collection.a"])
        #expect(WorksUploadCard.newestFirst(list: nil, stored: stored).map(\.id) == ["recent.n1"])
        #expect(WorksUploadCard.newestFirst(list: nil, stored: nil).isEmpty)
    }

    @Test func aCollectionUploadOpensItsFirstPageStillWatchable() throws {
        let list = try WorksFixtures.uploadList([
            WorksFixtures.upload(id: "a", date: "2019-01-01", niconico: "sm1", youtube: ["yt1"])
        ])
        let stored = try WorksFixtures.stored(uploads: [
            "a": WorksFixtures.state(videos: [WorksFixtures.storedVideo(id: "yt1", availability: "public")])
        ])

        let card = try #require(WorksUploadCard.newestFirst(list: list, stored: stored).first)

        #expect(card.watch?.platform == .niconico)
        #expect(card.watch?.url == URL(string: "https://www.nicovideo.jp/watch/sm1"))
    }

    @Test func aRemovedPageIsSkippedAndNothingLeftMeansNoPage() throws {
        let list = try WorksFixtures.uploadList([
            WorksFixtures.upload(id: "a", date: "2019-01-01", youtube: ["yt1"], bilibili: "BV1"),
            WorksFixtures.upload(id: "b", date: "2019-01-02", youtube: ["yt2"]),
        ])
        let stored = try WorksFixtures.stored(uploads: [
            "a": WorksFixtures.state(videos: [WorksFixtures.storedVideo(id: "yt1", availability: "removed")]),
            "b": WorksFixtures.state(videos: [WorksFixtures.storedVideo(id: "yt2", availability: "private")]),
        ])

        let cards = WorksUploadCard.newestFirst(list: list, stored: stored)

        #expect(cards.first { $0.sourceID == "a" }?.watch?.platform == .bilibili)
        #expect(cards.first { $0.sourceID == "b" }?.watch == nil)
    }

    @Test func aNewerVideoOpensItsOwnPageAndKeepsItsTranslations() throws {
        let stored = try WorksFixtures.stored(recent: [
            WorksFixtures.recent(
                id: "n1", source: "bilibili", publishedAt: "2026-11-08T08:00:00Z",
                translations: ["en": ["text": "Translated", "origin": "manual", "platform": NSNull()]])
        ])

        let card = try #require(WorksUploadCard.newestFirst(list: nil, stored: stored).first)

        #expect(card.watch?.url == URL(string: "https://example.com/watch/n1"))
        #expect(card.watch?.platform == .bilibili)
        #expect(card.title == "Recent n1")
        #expect(card.translations?.en?.text == "Translated")
        #expect(card.date == JapanDate(year: 2026, month: 11, day: 8))
    }
}
