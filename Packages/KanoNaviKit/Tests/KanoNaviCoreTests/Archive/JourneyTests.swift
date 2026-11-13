import Foundation
import Testing

@testable import KanoNaviCore

struct JourneyTests {
    private func journey() async throws -> JourneyResponse {
        try await ArchiveFixtures.client(["/api/journey": "journey"]).journey()
    }

    @Test func decodesBranchesAndPortrait() async throws {
        let journey = try await journey()
        #expect(journey.updatedAt == JapanDate(year: 2026, month: 11, day: 7))
        let branch = try #require(journey.branches.first)
        #expect(branch.id == "singer")
        #expect(branch.tone == "honey")
        #expect(branch.since == "2010")
        #expect(branch.label.text(in: .zhHans) == nil)
        let portrait = try #require(branch.portrait)
        #expect(portrait.url.absoluteString == "https://api.example.com/media/journey/portrait.jpg")
        #expect(portrait.focus == "50% 0%")
    }

    @Test func milestonesKeepTheirDatePrecision() async throws {
        let milestones = try await journey().milestones
        #expect(milestones.map(\.date.precision) == [.year, .month, .day])
        #expect(milestones.map(\.date.rawValue) == ["2010", "2012-08", "2016-09-07"])
        #expect(milestones[0].dateEnd == nil)
        #expect(milestones[1].dateNote == "C82")
        #expect(milestones[2].dateEnd == JapanDate(year: 2016, month: 9, day: 30))
        #expect(milestones[0].highlight)
        #expect(milestones[0].detail == nil)
        #expect(milestones[0].sourceURL == nil)
    }

    @Test func linkLabelsAreCodes() async throws {
        let links = try await journey().milestones[0].links
        #expect(links.map(\.label) == [.agency, .unknown("newsletter")])
        #expect(links[0].url.absoluteString == "https://agency.example.com/news/1")
    }

    @Test func fixedMediaKeepsProvenanceUnresolved() async throws {
        let media = try #require(try await journey().milestones[1].media.first)
        #expect(media.origin == .fixed)
        #expect(media.url.absoluteString == "https://api.example.com/media/journey/frame.png")
        #expect(media.branches == ["singer", "mahoro"])
        #expect(media.category == .frame)
        #expect(media.date == nil)
        #expect(media.dateKind == .stream)
        #expect(media.sourceKind == .streamArchive)
        #expect(media.frameTime == "01:05:00")
        #expect(media.credit == "© Synthetic Studio")
        #expect(media.originalStream?.absoluteString == "https://video.example.com/watch/1?t=3900")
        #expect(media.releaseID == nil)
        #expect(media.cancelled == nil)
        #expect(media.cover == nil)
    }

    @Test func releaseMediaCarriesItsWorksCover() async throws {
        let milestone = try await journey().milestones[2]
        #expect(milestone.releaseID == "2016-09-07-abc123")
        let media = try #require(milestone.media.first)
        #expect(media.origin == .release)
        #expect(media.category == .cover)
        #expect(media.dateKind == .release)
        #expect(media.sourceKind == .officialCover)
        #expect(media.releaseID == "2016-09-07-abc123")
        #expect(media.cancelled == false)
        #expect(media.sourcePage?.absoluteString == "https://label.example.com/release/1/cover")
        let cover = try #require(media.cover)
        #expect(cover.url.absoluteString == "https://api.example.com/media/works/cover.jpg")
        #expect(cover.sourceURL?.absoluteString == "https://label.example.com/release/1/cover")
        #expect(cover.thirdParty == false)
    }

    @Test func unknownMediaCodesDecode() async throws {
        let media = try #require(try await journey().galleryOnly.first)
        #expect(media.origin == .unknown("sticker"))
        #expect(media.category == .unknown("poster"))
        #expect(media.dateKind == .unknown("printing"))
        #expect(media.sourceKind == .unknown("museum"))
        #expect(media.note == "newNote")
        #expect(media.sourceURL?.absoluteString == "https://shop.example.com/item/1.jpg")
    }

    @Test func mismatchedDatePrecisionIsADecodingError() throws {
        let json = #"""
            {"id":"m","date":"2016-09","datePrecision":"day","dateEnd":null,"dateNote":null,"branch":"singer",
            "kind":"stream","highlight":false,"title":{"ja":"a","zh-CN":null,"en":null},"detail":null,
            "sourceUrl":null,"links":[],"releaseId":null,"media":[]}
            """#
        #expect(throws: DecodingError.self) {
            try ArchiveFixtures.decode(JourneyMilestone.self, from: json)
        }
    }

    @Test func milestoneEncodesItsDatePrecision() throws {
        let json = #"""
            {"id":"m","date":"2016-09","datePrecision":"month","dateEnd":null,"dateNote":null,"branch":"singer",
            "kind":"stream","highlight":false,"title":{"ja":"a","zh-CN":null,"en":null},"detail":null,
            "sourceUrl":null,"links":[],"releaseId":null,"media":[]}
            """#
        let milestone = try ArchiveFixtures.decode(JourneyMilestone.self, from: json)
        let encoded = try JSONEncoder.kanoNavi().encode(milestone)
        let object = try #require(try JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        #expect(object["datePrecision"] as? String == "month")
        #expect(try JSONDecoder.kanoNavi().decode(JourneyMilestone.self, from: encoded) == milestone)
    }
}
