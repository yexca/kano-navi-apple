import Foundation
import Testing

@testable import KanoNaviCore

struct WorksTests {
    private func works() async throws -> WorksResponse {
        try await ArchiveFixtures.client(["/api/works": "works"]).works()
    }

    @Test func decodesTheSummary() async throws {
        let works = try await works()
        #expect(works.summary.personal == 2)
        #expect(works.summary.firstYear == 2010)
        #expect(works.summary.lastYear == 2026)
        #expect(works.updatedAt == JapanDate(year: 2026, month: 11, day: 7))
    }

    @Test func releaseWithoutEditions() async throws {
        let release = try await works().personal[0]
        #expect(release.format == .doujin)
        #expect(release.editions.isEmpty)
        #expect(release.catalog == nil)
        #expect(release.printedDisc)
        #expect(release.tracks.first?.listen == nil)
        #expect(release.covers.first?.url.absoluteString == "https://api.example.com/media/works/album.jpg")
        #expect(release.covers.first?.sourceURL?.absoluteString == "https://db.example.com/release/1")
        #expect(release.disc?.credit?.role == .scan)
        #expect(release.disc?.credit?.url?.absoluteString == "https://people.example.com/scanner")
        #expect(release.cutout?.thirdParty == nil)
        #expect(release.cutout?.caption == nil)
        #expect(release.cutout?.url.absoluteString == "https://api.example.com/media/works/cutout.png")
    }

    @Test func releaseWithEditions() async throws {
        let release = try await works().personal[1]
        #expect(release.format == .unknown("maxi"))
        #expect(release.unit == "Synthetic Unit")
        #expect(
            release.discs.first?.image.url.absoluteString == "https://api.example.com/media/works/disc1.jpg")
        #expect(release.discs.first?.image.credit == WorksImageCredit(role: .photo, name: nil, url: nil))
        #expect(release.stores.first?.links.first?.platform == "new_store")

        let edition = try #require(release.editions.first)
        #expect(edition.name?.text(in: .en) == "Limited edition")
        #expect(edition.packaging == nil)
        #expect(edition.date == JapanDate(year: 2017, month: 5, day: 1))
        #expect(edition.jan.isEmpty)
        #expect(edition.covers.first?.url.absoluteString == "https://api.example.com/media/works/limited.jpg")
        #expect(edition.bonuses.map { $0.text(in: .en) } == ["Sticker"])
        #expect(
            edition.bonusImages.first?.url.absoluteString == "https://api.example.com/media/works/sticker.png"
        )
        #expect(edition.bonusImages.first?.credit?.role == .fan)
        #expect(
            edition.storeBonuses.first?.images.first?.url.absoluteString
                == "https://api.example.com/media/works/card.jpg")
        #expect(edition.storeBonuses.first?.store.text(in: .en) == "Shop A")
        #expect(edition.stores.map { $0.item?.text(in: .en) } == [nil, "Instrumental"])
        #expect(edition.stores[0].links.map(\.hiRes) == [false, true])
        #expect(edition.tracks.map(\.disc) == [1, 2])
        #expect(edition.tracks[1].discLabel?.text(in: .en) == "DVD")
    }

    @Test func listenKeepsPlatformIDs() async throws {
        let release = try await works().personal[1]
        let listen = try #require(release.tracks.first?.listen)
        #expect(
            listen
                == PlatformVideoIDs(
                    niconico: "sm100", youtube: ["yt-AAA_1"], youtubeMembers: ["ytMembers2"],
                    bilibili: "BV1xx"))
        let empty = try #require(release.editions.first?.tracks.first?.listen)
        #expect(empty.isEmpty)
        #expect(empty.links.isEmpty)
        #expect(release.editions.first?.tracks.last?.listen == nil)
    }

    @Test func participationWork() async throws {
        let work = try #require(try await works().participation.first)
        #expect(work.roles == [.vocal, .unknown("dance")])
        #expect(work.forms == ["digital", "newForm"])
        #expect(work.unit == nil)
        #expect(work.event.isEmpty)
        #expect(work.catalog.isEmpty)
        #expect(work.sourceURL?.absoluteString == "https://db.example.com/release/3")
        #expect(work.cover?.url.absoluteString == "https://api.example.com/media/works/compilation.jpg")
        #expect(work.cover?.sourceLabel == "Synthetic Store")
        #expect(work.tracks.map(\.kano) == [false, true])
        #expect(work.tracks[1].kanoCredits == [.lyrics, .unknown("mixing")])
    }

    @Test func uploadListDecodes() async throws {
        let list = try await ArchiveFixtures.client(["/api/works/upload-list": "works-upload-list"])
            .worksUploadList()
        #expect(list.uploads.map(\.kind) == [.cover, .unknown("medley")])
        let medley = list.uploads[1]
        #expect(medley.with == "A Friend")
        #expect(medley.albums == ["Synthetic Album (2022)"])
        #expect(medley.tracks == ["Song A", "Song B"])
        #expect(medley.videoIDs.youtube == ["yt1", "bad id"])
        #expect(list.uploads[0].originalArtist.isEmpty)
        #expect(list.uploads[0].bilibili == nil)
    }
}
