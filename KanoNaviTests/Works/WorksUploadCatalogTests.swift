import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// The upload list joined with the stored data by upload ID, filtered,
/// searched and ordered.
struct WorksUploadCatalogTests {
    private let list: WorksUploadListResponse

    init() throws {
        // The collection's order: oldest first.
        list = try WorksFixtures.uploadList([
            WorksFixtures.upload(
                id: "u1", date: "2012-01-01", song: "Alpha", originalArtist: "Example P", niconico: "sm1",
                albums: ["First Album"]),
            WorksFixtures.upload(
                id: "u2", date: "2021-05-05", song: "Beta", kind: "original", with: "Example Friend",
                youtube: ["yt2"], youtubeMembers: ["ytm2"], bilibili: "BV2", bilibiliTitle: "贝塔"),
            WorksFixtures.upload(
                id: "u3", date: "2021-09-09", song: "Gamma", kind: "mv", youtube: ["yt3a", "yt3b"]),
            WorksFixtures.upload(
                id: "u4", date: "2024-02-02", song: "Delta Medley", kind: "radio", youtube: ["yt4"],
                tracks: ["Epsilon", "Zeta"]),
        ])
    }

    @Test func withoutStoredDataTheListShowsOnItsOwn() {
        let catalog = WorksUploadCatalog(list: list, stored: nil)

        #expect(catalog.items.map(\.id) == ["u1", "u2", "u3", "u4"])
        #expect(catalog.items.allSatisfy { $0.cover == nil && $0.isGone == false && $0.lengthSeconds == nil })
        #expect(catalog.showsCovers == false)
        #expect(catalog.items[1].links.map(\.link.platform) == [.youtube, .youtube, .bilibili])
        #expect(catalog.items[1].links.map(\.link.isMembersOnly) == [false, true, false])
        #expect(catalog.items[1].links.allSatisfy { $0.isGone == false })
    }

    @Test func joinsCoversAndVideosByUploadID() throws {
        let stored = try WorksFixtures.stored(uploads: [
            "u2": WorksFixtures.state(
                cover: WorksFixtures.cover("u2"),
                videos: [
                    WorksFixtures.storedVideo(id: "yt2", availability: "public", durationSeconds: 245),
                    WorksFixtures.storedVideo(source: "bilibili", id: "BV2", availability: "removed"),
                ]),
            "unlisted": WorksFixtures.state(cover: WorksFixtures.cover("stray")),
        ])

        let catalog = WorksUploadCatalog(list: list, stored: stored)
        let joined = catalog.items[1]

        #expect(catalog.items.count == 4)
        #expect(catalog.showsCovers)
        #expect(joined.cover?.url.absoluteString == "https://example.com/media/u2")
        #expect(joined.lengthSeconds == 245)
        #expect(joined.isGone == false)
        #expect(joined.links.map(\.isGone) == [false, false, true])
        #expect(joined.hasMembersOnlyVideo)
        // The others have no stored data and still show.
        #expect(catalog.items[0].cover == nil)
        #expect(catalog.items[0].links.map(\.link.platform) == [.niconico])
    }

    @Test func partialStoredDataLeavesTheRestUnknown() throws {
        let stored = try WorksFixtures.stored(uploads: [
            // A cover the cache has not measured, and no videos.
            "u1": WorksFixtures.state(cover: WorksFixtures.cover("u1", width: nil, height: nil)),
            // Videos whose length and availability are unknown, and no cover.
            "u3": WorksFixtures.state(videos: [
                WorksFixtures.storedVideo(id: "yt3a"), WorksFixtures.storedVideo(id: "yt3b"),
            ]),
        ])

        let catalog = WorksUploadCatalog(list: list, stored: stored)

        let unmeasured = try #require(catalog.items[0].cover)
        #expect(unmeasured.width == nil)
        #expect(
            MediaImageSource(url: unmeasured.url, width: unmeasured.width, height: unmeasured.height)
                .pixelSize == nil)
        #expect(catalog.items[2].cover == nil)
        #expect(catalog.items[2].lengthSeconds == nil)
        #expect(catalog.items[2].isGone == false)
        #expect(catalog.items[2].links.allSatisfy { $0.isGone == false })
        #expect(WorksDateFormat.length(seconds: catalog.items[2].lengthSeconds) == nil)
        #expect(catalog.showsCovers)
    }

    @Test func anUploadIsGoneOnlyWhenNoStoredYouTubeVideoCanBeWatched() throws {
        let stored = try WorksFixtures.stored(uploads: [
            "u3": WorksFixtures.state(videos: [
                WorksFixtures.storedVideo(id: "yt3a", availability: "removed"),
                WorksFixtures.storedVideo(id: "yt3b", availability: "private"),
            ]),
            "u2": WorksFixtures.state(videos: [
                WorksFixtures.storedVideo(id: "yt2", availability: "removed"),
                WorksFixtures.storedVideo(id: "ytm2", availability: "members"),
            ]),
            "u4": WorksFixtures.state(videos: [
                WorksFixtures.storedVideo(source: "bilibili", id: "BV4", availability: "removed")
            ]),
        ])

        let catalog = WorksUploadCatalog(list: list, stored: stored)

        #expect(catalog.items[2].isGone)
        #expect(catalog.items[2].links.map(\.isGone) == [true, true])
        #expect(catalog.items[1].isGone == false)
        #expect(catalog.items[1].links.map(\.isGone) == [true, false, false])
        // No stored YouTube video at all: nothing says it is gone.
        #expect(catalog.items[3].isGone == false)
    }

    @Test func kindChoicesCountTheWholeListInAFixedOrder() {
        let options = WorksUploadCatalog(list: list, stored: nil).options

        #expect(options.map(\.code) == [nil, "cover", "original", "mv", "other"])
        #expect(options.map(\.count) == [4, 1, 1, 1, 1])
    }

    @Test func narrowsToAKindAndGroupsByYear() {
        let catalog = WorksUploadCatalog(list: list, stored: nil)

        let all = catalog.groups(kind: nil, order: .newestFirst)
        #expect(all.map(\.year) == [2024, 2021, 2012])
        #expect(all[1].items.map(\.id) == ["u3", "u2"])

        #expect(catalog.groups(kind: "mv", order: .newestFirst).flatMap(\.items).map(\.id) == ["u3"])
        // A kind the app does not name is listed under Other.
        #expect(catalog.groups(kind: "other", order: .newestFirst).flatMap(\.items).map(\.id) == ["u4"])
        #expect(catalog.groups(kind: "game", order: .newestFirst).isEmpty)
        #expect(
            catalog.groups(kind: nil, order: .oldestFirst).flatMap(\.items).map(\.id) == [
                "u1", "u2", "u3", "u4",
            ])
    }

    @Test(arguments: [
        ("", ["u1", "u2", "u3", "u4"]), ("   ", ["u1", "u2", "u3", "u4"]), ("alpha", ["u1"]),
        ("example", ["u1", "u2"]), ("EXAMPLE friend", ["u2"]), ("first album", ["u1"]), ("zeta", ["u4"]),
        ("贝塔", ["u2"]), ("ｂｅｔａ", ["u2"]), ("nothing", []),
    ])
    func searchMatchesEveryWordAcrossAnUploadsText(query: String, expected: [String]) {
        let found = WorksUploadCatalog(list: list, stored: nil).searching(query)

        #expect(found.items.map(\.id) == expected)
    }

    @Test func choicesCountWhatASearchFound() {
        let options = WorksUploadCatalog(list: list, stored: nil).searching("example").options

        #expect(options.map(\.code) == [nil, "cover", "original"])
        #expect(options.map(\.count) == [2, 1, 1])
    }
}
