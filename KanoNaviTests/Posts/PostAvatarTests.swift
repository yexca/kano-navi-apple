import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// How a post's avatar resolves from the board's `accountAvatars` and the
/// profile avatar, as the web board resolves it.
@MainActor
struct PostAvatarTests {
    private let profileURL = URL(string: "https://example.com/media/avatar")
    private let kanoURL = URL(string: "https://example.com/media/account-avatar/x/kano_example?v=2")

    private func avatar(_ json: [String: Any], _ avatars: [String: URL?]?) throws -> PostAvatar {
        try PostFixtures.card(json, accountAvatars: avatars, profileAvatarURL: profileURL).avatar
    }

    @Test func ownPostWithAnEntryShowsTheAccountsAvatar() throws {
        let url = try #require(kanoURL)

        let avatar = try avatar(PostFixtures.json(id: "1", handle: "kano_example"), ["x:kano_example": url])

        #expect(avatar == .image(url))
    }

    @Test func handleMatchesWithoutCaseOrAtSign() throws {
        let url = try #require(kanoURL)

        let avatar = try avatar(PostFixtures.json(id: "1", handle: "@Kano_Example"), ["x:kano_example": url])

        #expect(avatar == .image(url))
    }

    @Test(arguments: [nil, [:]] as [[String: URL?]?])
    func ownPostWithoutAnEntryFallsBackToTheProfileAvatar(_ avatars: [String: URL?]?) throws {
        let profileURL = try #require(profileURL)

        let avatar = try avatar(PostFixtures.json(id: "1", handle: "kano_example"), avatars)

        #expect(avatar == .image(profileURL))
    }

    @Test func ownPostWithoutAnyAvatarIsAPlaceholder() throws {
        let card = try PostFixtures.card(PostFixtures.json(id: "1", handle: "kano_example"))

        #expect(card.avatar == .placeholder)
    }

    @Test(arguments: [false, true])
    func hiddenAvatarShowsTheHandlesInitial(_ promoted: Bool) throws {
        let avatar = try avatar(
            PostFixtures.json(id: "1", handle: "kano_example", promoted: promoted), ["x:kano_example": nil])

        #expect(avatar == .initial("K"))
    }

    @Test func promotedPostWithoutAnEntryShowsTheHandlesInitial() throws {
        let avatar = try avatar(PostFixtures.json(id: "1", handle: "agency_example", promoted: true), [:])

        #expect(avatar == .initial("A"))
    }

    @Test func initialSkipsLeadingMarks() throws {
        let avatar = try avatar(PostFixtures.json(id: "1", handle: "_Kano_example"), ["x:_kano_example": nil])

        #expect(avatar == .initial("K"))
    }

    @Test func promotedPostWithAnEntryShowsItsAvatar() throws {
        let url = try #require(URL(string: "https://example.com/media/account-avatar/x/agency_example"))

        let avatar = try avatar(
            PostFixtures.json(id: "1", handle: "agency_example", promoted: true), ["x:agency_example": url])

        #expect(avatar == .image(url))
    }

    @Test func entryOfAnotherSourceDoesNotApply() throws {
        let url = try #require(kanoURL)
        let profileURL = try #require(profileURL)

        let avatar = try avatar(
            PostFixtures.json(id: "1", source: "bilibili", handle: "kano_example"), ["x:kano_example": url])

        #expect(avatar == .image(profileURL))
    }

    @Test func ownBilibiliPostShowsTheProfileAvatar() throws {
        let profileURL = try #require(profileURL)

        let avatar = try avatar(PostFixtures.json(id: "1", source: "bilibili", handle: "316381099"), [:])

        #expect(avatar == .image(profileURL))
    }

    @Test func promotedBilibiliPostShowsTheSymbol() throws {
        let avatar = try avatar(
            PostFixtures.json(id: "1", source: "bilibili", handle: "316381099", promoted: true), [:])

        #expect(avatar == .symbol)
    }

    @Test func ownUnnamedXPostShowsTheProfileAvatar() throws {
        let profileURL = try #require(profileURL)

        let avatar = try avatar(PostFixtures.json(id: "1", handle: nil), [:])

        #expect(avatar == .image(profileURL))
    }

    @Test func promotedUnnamedXPostShowsTheSymbol() throws {
        let avatar = try avatar(PostFixtures.json(id: "1", handle: nil, promoted: true), [:])

        #expect(avatar == .symbol)
    }

    @Test func dashboardSnapshotCarriesItsResolvedMap() throws {
        var fixture = DashboardFixture()
        fixture.accountAvatars = [
            "x:kano_example": "https://example.com/a.png", "x:hidden_example": NSNull(),
        ]

        let avatars = try #require(try fixture.dashboard().accountAvatars)

        #expect(avatars["x:kano_example"] == .some(URL(string: "https://example.com/a.png")))
        #expect(avatars["x:hidden_example"] == .some(nil))
    }
}
