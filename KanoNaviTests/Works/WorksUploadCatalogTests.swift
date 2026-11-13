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
        #expect(catalog.showsCovers(kind: nil) == false)
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
        #expect(catalog.showsCovers(kind: nil))
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
        #expect(catalog.showsCovers(kind: nil))
    }

    @Test func anUploadIsGoneOnlyWhenEveryWatchPageIsAStoredVideoThatIsGone() throws {
        let stored = try WorksFixtures.stored(uploads: [
            "u3": WorksFixtures.state(videos: [
                WorksFixtures.storedVideo(id: "yt3a", availability: "removed"),
                WorksFixtures.storedVideo(id: "yt3b", availability: "private"),
            ]),
            // Its Bilibili page is not stored, so it may still be there.
            "u2": WorksFixtures.state(videos: [
                WorksFixtures.storedVideo(id: "yt2", availability: "removed"),
                WorksFixtures.storedVideo(id: "ytm2", availability: "removed"),
            ]),
            // A stored video that is none of the upload's pages says nothing about them.
            "u4": WorksFixtures.state(videos: [
                WorksFixtures.storedVideo(source: "bilibili", id: "BV4", availability: "removed")
            ]),
        ])

        let catalog = WorksUploadCatalog(list: list, stored: stored)

        #expect(catalog.items[2].isGone)
        #expect(catalog.items[2].links.map(\.isGone) == [true, true])
        #expect(catalog.items[1].isGone == false)
        #expect(catalog.items[1].links.map(\.isGone) == [true, true, false])
        #expect(catalog.items[3].isGone == false)
        #expect(catalog.items[3].links.map(\.isGone) == [false])
    }

    @Test func aRemovedVideoDoesNotHideAnotherPageOfTheUpload() throws {
        let list = try WorksFixtures.uploadList([
            WorksFixtures.upload(id: "nico", date: "2012-01-01", niconico: "sm9", youtube: ["yt9"]),
            WorksFixtures.upload(id: "two", date: "2012-01-02", youtube: ["yta", "ytb"]),
            WorksFixtures.upload(id: "bili", date: "2012-01-03", youtube: ["ytc"], bilibili: "BVc"),
        ])
        let stored = try WorksFixtures.stored(uploads: [
            "nico": WorksFixtures.state(videos: [
                WorksFixtures.storedVideo(id: "yt9", availability: "removed")
            ]),
            // Only one of the two YouTube videos is stored.
            "two": WorksFixtures.state(videos: [WorksFixtures.storedVideo(id: "yta", availability: "private")]
            ),
            "bili": WorksFixtures.state(videos: [
                WorksFixtures.storedVideo(id: "ytc", availability: "removed"),
                WorksFixtures.storedVideo(source: "bilibili", id: "BVc", availability: "public"),
            ]),
        ])

        let items = WorksUploadCatalog(list: list, stored: stored).items

        #expect(items.map(\.isGone) == [false, false, false])
        // niconico first, then YouTube: only the YouTube page is marked.
        #expect(items[0].links.map(\.isGone) == [false, true])
        #expect(items[1].links.map(\.isGone) == [true, false])
        #expect(items[2].links.map(\.isGone) == [true, false])
    }

    @Test func anUploadWithoutAnyWatchPageIsNotCalledGone() throws {
        let list = try WorksFixtures.uploadList([WorksFixtures.upload(id: "bare", date: "2012-01-01")])
        let stored = try WorksFixtures.stored(uploads: [
            "bare": WorksFixtures.state(videos: [WorksFixtures.storedVideo(id: "x", availability: "removed")])
        ])

        let item = try #require(WorksUploadCatalog(list: list, stored: stored).items.first)

        #expect(item.links.isEmpty)
        #expect(item.isGone == false)
    }

    @Test func aPageTheRecordListsTwiceShowsOnce() throws {
        let list = try WorksFixtures.uploadList([
            WorksFixtures.upload(
                id: "dup", date: "2012-01-01", youtube: ["same", "same", "other"], youtubeMembers: ["same"])
        ])

        let links = try #require(WorksUploadCatalog(list: list, stored: nil).items.first).links

        #expect(links.map(\.link.id) == ["same", "other"])
        #expect(links.map(\.link.isMembersOnly) == [false, false])
        #expect(Set(links.map(\.id)).count == links.count)
    }

    @Test func aTracksWatchPagesShowOnceEach() {
        let listen = PlatformVideoIDs(
            niconico: "sm1", youtube: ["a", "a"], youtubeMembers: ["a"], bilibili: "BV1")

        let links = WorksUploadLink.links(of: listen)

        #expect(links.map(\.link.platform) == [.niconico, .youtube, .bilibili])
        #expect(links.allSatisfy { $0.isGone == false })
    }

    @Test func coverColumnFollowsTheRowsShownForTheKind() throws {
        // Only the original has a cover; the cover songs and the MV have none.
        let stored = try WorksFixtures.stored(uploads: [
            "u2": WorksFixtures.state(cover: WorksFixtures.cover("u2"))
        ])
        let catalog = WorksUploadCatalog(list: list, stored: stored)

        #expect(catalog.showsCovers(kind: nil))
        #expect(catalog.showsCovers(kind: "original"))
        #expect(catalog.showsCovers(kind: "cover") == false)
        #expect(catalog.showsCovers(kind: "mv") == false)
        // A search that leaves the cover out leaves the column out too.
        #expect(catalog.searching("alpha").showsCovers(kind: nil) == false)
        #expect(catalog.searching("beta").showsCovers(kind: nil))
    }

    @Test func emptyStateSaysWhyNothingIsListed() {
        #expect(WorksUploadsEmptyState(isEmpty: false, isSearching: true, kind: "mv") == nil)
        #expect(WorksUploadsEmptyState(isEmpty: true, isSearching: true, kind: nil) == .search)
        #expect(WorksUploadsEmptyState(isEmpty: true, isSearching: true, kind: "mv") == .search)
        #expect(WorksUploadsEmptyState(isEmpty: true, isSearching: false, kind: "mv") == .kind)
        #expect(WorksUploadsEmptyState(isEmpty: true, isSearching: false, kind: nil) == .list)
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
