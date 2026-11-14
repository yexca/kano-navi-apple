import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct VideoTimelineItemTests {
    private let locale = Locale(identifier: "en_US")

    @Test func publishedVideoReadsFormTagAndJapanDate() throws {
        // 2026-11-12 16:00 UTC is November 13 in Japan.
        let card = try card(
            VideoFixtures.json(id: "A", formCode: "archive", tag: "game", publishedAt: "2026-11-12T16:00:00Z")
        )

        #expect(card.metaParts(locale: locale) == ["Archive", "Gameplay", "Fri, Nov 13"])
        #expect(card.metaLine(locale: locale) == "Archive · Gameplay · Fri, Nov 13")
        #expect(card.coverBadge == nil)
    }

    @Test func reservationLeavesItsStatusToTheCoverAndGivesTheJapanTime() throws {
        let card = try card(
            VideoFixtures.json(
                id: "U", phase: "upcoming", formCode: "upcoming", tag: "talk",
                scheduledAt: "2026-11-15T02:00:00Z", kind: "stream"))

        let parts = card.metaParts(locale: locale)

        #expect(parts.count == 2)
        #expect(parts.first == "Talk")
        #expect(parts.last?.hasPrefix("Sun, Nov 15") == true)
        #expect(parts.last?.contains("11:00") == true)
        #expect(parts.last?.hasSuffix("JST") == true)
        #expect(card.coverBadge == .upcoming(isPremiere: false))
    }

    @Test func premiereReservationIsBadgedAsAPremiere() throws {
        let card = try card(
            VideoFixtures.json(id: "P", phase: "upcoming", formCode: "upcoming", kind: "premiere"))

        #expect(card.coverBadge == .upcoming(isPremiere: true))
    }

    @Test(arguments: [
        ("live", VideoCoverBadge?.some(.live)), ("started", .started), ("cancelled", .cancelled),
        ("past", nil),
    ])
    func phaseGivesTheCoverBadge(phase: String, badge: VideoCoverBadge?) throws {
        #expect(try card(VideoFixtures.json(id: "V", phase: phase)).coverBadge == badge)
    }

    @Test func shortLeavesItsFormToTheCover() throws {
        let card = try card(VideoFixtures.json(id: "S", formCode: "short", tag: nil, isShort: true))

        #expect(card.metaParts(locale: locale) == ["Mon, Nov 9"])
    }

    @Test func itemOpensItsOwnPageAndOffersTheAlternates() throws {
        let card = try card(
            VideoFixtures.json(
                id: "W", alternates: [["source": "bilibili", "url": "https://example.com/bili/W"]]))

        #expect(card.primaryLink?.url.absoluteString == "https://example.com/watch/W")
        #expect(card.links.map(\.destination) == [.platform(.youtube), .platform(.bilibili)])
    }

    @Test func chosenPlatformsPageIsTheOneTheItemOpens() throws {
        let card = try card(
            VideoFixtures.json(
                id: "W", alternates: [["source": "bilibili", "url": "https://example.com/bili/W"]]))

        let shown = try #require(VideoTimelineFilter(platform: .bilibili).apply(to: card))

        #expect(shown.primaryLink?.url.absoluteString == "https://example.com/bili/W")
        #expect(shown.primaryLink?.destination == .platform(.bilibili))
    }

    @Test func accessibilityLabelReadsTitleFormDateAndLength() throws {
        let card = try card(
            VideoFixtures.json(
                id: "A", formCode: "archive", tag: "game", availability: "members",
                publishedAt: "2026-11-12T16:00:00Z", durationSeconds: 4171))

        let label = card.accessibilityLabel(title: "A title", locale: locale)

        #expect(label.hasPrefix("A title, Archive, Gameplay, Members only, Fri, Nov 13 "))
        #expect(label.contains("JST, "))
        #expect(label.hasSuffix("1 hour, 9 minutes, 31 seconds"))
    }

    @Test func accessibilityLabelNamesTheStatusInsteadOfTheForm() throws {
        let card = try card(VideoFixtures.json(id: "L", phase: "live", formCode: "stream"))

        #expect(card.accessibilityLabel(title: "Live now", locale: locale).hasPrefix("Live now, Live, "))
    }

    private func card(_ json: [String: Any]) throws -> VideoCard {
        VideoCard(video: try VideoFixtures.video(json))
    }
}
