import KanoNaviCore

/// The recent posts' account filter: each of the board's X accounts by
/// handle, then one Bilibili choice for its Bilibili accounts, counted over
/// the dashboard's posts and applied on the device.
enum PostRecentFilter {
    /// The Bilibili choice's code. A colon never appears in an X handle, so
    /// it cannot meet one.
    static let bilibiliCode = "source:bilibili"

    /// The choices after All: the X accounts in the metadata's order, then
    /// Bilibili when the board follows a Bilibili account.
    static func accounts(meta: DashboardMeta) -> [PostFilterAccount] {
        let bilibili =
            (meta.bilibiliAccounts ?? []).isEmpty
            ? [] : [PostFilterAccount(code: bilibiliCode, isBilibili: true)]
        return meta.xAccounts.map { PostFilterAccount(code: handle($0), isBilibili: false) } + bilibili
    }

    /// The filter's choices: all posts, then each account with its share of
    /// the recent posts.
    static func options(cards: [PostCard], accounts: [PostFilterAccount]) -> [ArchiveFilterOption] {
        var counts: [String: Int] = [:]
        for account in accounts {
            counts[account.code.lowercased()] = cards.count { matches($0, code: account.code) }
        }
        return PostAccountFilter.options(accounts: accounts, counts: counts, allCount: cards.count)
    }

    /// The posts one choice shows: all of them for `nil`.
    static func cards(_ cards: [PostCard], code: String?) -> [PostCard] {
        guard let code else { return cards }
        return cards.filter { matches($0, code: code) }
    }

    /// Whether a post is from the account a choice names. Handles compare
    /// without case, as X treats them.
    static func matches(_ card: PostCard, code: String) -> Bool {
        if code == bilibiliCode {
            return card.isBilibili
        }
        guard case .x(let handle) = card.account else { return false }
        return handle.lowercased() == Self.handle(code).lowercased()
    }

    /// A handle without the leading `@` the metadata may carry.
    private static func handle(_ account: String) -> String {
        account.hasPrefix("@") ? String(account.dropFirst()) : account
    }
}
