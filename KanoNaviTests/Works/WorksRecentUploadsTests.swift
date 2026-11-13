import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// The videos newer than the collection that the Uploads screen shows first.
struct WorksRecentUploadsTests {
    @Test func nothingWithoutStoredDataOrNewerVideos() throws {
        #expect(WorksRecentUploads(nil) == nil)
        #expect(WorksRecentUploads(try WorksFixtures.stored()) == nil)
    }

    @Test func showsAFewUntilAskedForTheRest() throws {
        let stored = try WorksFixtures.stored(
            recent: (1...5).map { WorksFixtures.recent(id: "n\($0)") }, recentTotal: 5)

        let recent = try #require(WorksRecentUploads(stored))

        #expect(recent.shown(expanded: false).map(\.id) == ["n1", "n2", "n3"])
        #expect(recent.shown(expanded: true).count == 5)
        #expect(recent.collapsedCount == 2)
        #expect(recent.unlistedCount == 0)
        #expect(recent.since == JapanDate(year: 2026, month: 11, day: 7))
    }

    @Test func saysWhenTheServiceCountedMoreThanItSent() throws {
        let stored = try WorksFixtures.stored(recent: [WorksFixtures.recent(id: "n1")], recentTotal: 60)

        let recent = try #require(WorksRecentUploads(stored))

        #expect(recent.total == 60)
        #expect(recent.unlistedCount == 59)
        #expect(recent.collapsedCount == 0)
    }

    @Test func aTotalBelowTheListIsRaisedToIt() throws {
        let stored = try WorksFixtures.stored(
            recent: [WorksFixtures.recent(id: "n1"), WorksFixtures.recent(id: "n2")], recentTotal: 0)

        let recent = try #require(WorksRecentUploads(stored))

        #expect(recent.total == 2)
        #expect(recent.unlistedCount == 0)
    }

    @Test func aVideoWithoutATimeOrCoverStillDecodes() throws {
        let stored = try WorksFixtures.stored(recent: [WorksFixtures.recent(id: "n1", origin: "mystery")])

        let video = try #require(WorksRecentUploads(stored)?.videos.first)

        #expect(video.publishedAt == nil)
        #expect(video.cover == nil)
        #expect(video.origin == .unknown("mystery"))
    }

    @MainActor @Test func titleFollowsTheContentLanguageThroughItsTranslations() throws {
        let stored = try WorksFixtures.stored(recent: [
            WorksFixtures.recent(
                id: "n1",
                translations: ["en": ["text": "English title", "origin": "manual", "platform": NSNull()]])
        ])
        let video = try #require(WorksRecentUploads(stored)?.videos.first)
        let english = Locale(identifier: "en")

        let translated = video.contentTitle.resolved(for: .en, interfaceLocale: english)
        let original = video.contentTitle.resolved(for: .ja, interfaceLocale: english)
        let missing = video.contentTitle.resolved(for: .zhHans, interfaceLocale: english)

        #expect(translated.text == "English title")
        #expect(translated.isTranslation)
        #expect(original.text == "Recent n1")
        #expect(original.isTranslation == false)
        #expect(missing.text == "Recent n1")
    }

    @MainActor @Test func linksLeadWithTheVideosOwnPageThenItsAlternates() throws {
        let stored = try WorksFixtures.stored(recent: [
            WorksFixtures.recent(
                id: "n1",
                alternates: [
                    ["source": "bilibili", "url": "https://example.com/bili/n1"],
                    ["source": "youtube", "url": "https://example.com/watch/n1"],
                ])
        ])
        let video = try #require(WorksRecentUploads(stored)?.videos.first)

        #expect(
            video.pageLinks.map(\.url.absoluteString) == [
                "https://example.com/watch/n1", "https://example.com/bili/n1",
            ])
        #expect(video.pageLinks.map(\.destination) == [.platform(.youtube), .platform(.bilibili)])
    }

    @MainActor @Test func alternatesEqualToEachOtherShowOnce() throws {
        let alternate: [String: Any] = ["source": "bilibili", "url": "https://example.com/bili/n1"]
        let stored = try WorksFixtures.stored(recent: [
            WorksFixtures.recent(id: "n1", alternates: [alternate, alternate])
        ])
        let video = try #require(WorksRecentUploads(stored)?.videos.first)

        #expect(
            video.pageLinks.map(\.url.absoluteString) == [
                "https://example.com/watch/n1", "https://example.com/bili/n1",
            ])
    }
}
