import Foundation
import KanoNaviCore

/// The identity card at the top of the Now tab: the profile's name, banner
/// and avatar, and its links, chosen as the web board's profile card chooses
/// them.
struct NowProfile: Equatable {
    /// An X account as a link labelled with its handle.
    struct XAccount: Equatable, Identifiable {
        var handle: String
        var url: URL

        var id: URL { url }
    }

    /// The dashboard's counts, each opening the tab it counts.
    struct Counts: Equatable {
        /// The window `counts.videos` covers, by the public API's contract:
        /// public videos published within the most recent seven days.
        static let videoWindowDays = 7

        var upcomingEvents: Int
        var posts: Int
        /// The days `posts` covers, the dashboard's post window.
        var postWindowDays: Int
        var videos: Int
    }

    var displayName: String
    var romanizedName: String
    var avatarURL: URL?
    var bannerURL: URL?
    /// Every X account in the link directory, in its order; the profile's
    /// own account when the directory has none.
    var xAccounts: [XAccount]
    var youtubeURL: URL
    /// The first Bilibili page in the link directory, if any.
    var bilibiliURL: URL?
    /// The dashboard summary's counts; `nil` when it has none.
    var counts: Counts?

    init(dashboard: Dashboard) {
        let profile = dashboard.profile
        displayName = profile.displayName
        romanizedName = profile.romanizedName
        avatarURL = profile.avatarURL
        bannerURL = profile.bannerURL
        youtubeURL = profile.youtubeURL

        var accounts: [XAccount] = []
        for url in dashboard.resources.map(\.url) where Self.isXAccount(url) {
            if accounts.contains(where: { $0.url == url }) == false {
                accounts.append(XAccount(handle: url.lastPathComponent, url: url))
            }
        }
        if accounts.isEmpty {
            accounts.append(XAccount(handle: profile.xURL.lastPathComponent, url: profile.xURL))
        }
        xAccounts = accounts

        bilibiliURL = dashboard.resources.first { $0.url.absoluteString.contains("bilibili.com") }?.url

        counts = dashboard.summary.counts.map { counts in
            Counts(
                upcomingEvents: counts.upcomingEvents, posts: counts.posts,
                postWindowDays: dashboard.meta.postWindowDays, videos: counts.videos)
        }
    }

    /// Whether `url` is an account's page on X: `https://x.com/<handle>` or
    /// the same on `twitter.com`, optionally with `www.`, and nothing after
    /// the handle.
    static func isXAccount(_ url: URL) -> Bool {
        url.absoluteString.wholeMatch(of: /https:\/\/(?:www\.)?(?:x|twitter)\.com\/[A-Za-z0-9_]+/) != nil
    }
}
