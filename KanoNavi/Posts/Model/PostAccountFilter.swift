import KanoNaviComponents
import KanoNaviCore

/// The post archive's account filter: the board's X accounts, then its
/// Bilibili accounts, each with its platform's logo and the month's count.
enum PostAccountFilter {
    /// The accounts from the dashboard's metadata, or, without a snapshot,
    /// the accounts the month counts, in their order.
    static func accounts(meta: DashboardMeta?, counts: [String: Int]) -> [PostFilterAccount] {
        guard let meta else {
            return counts.keys.sorted().map { PostFilterAccount(code: $0, isBilibili: false) }
        }
        return meta.xAccounts.map { PostFilterAccount(code: $0, isBilibili: false) }
            + (meta.bilibiliAccounts ?? []).map { PostFilterAccount(code: $0, isBilibili: true) }
    }

    /// The filter's choices: all posts, then each account with the month's
    /// count, which the API keys by lowercase handle. Counts are `nil` before
    /// the month loads.
    static func options(accounts: [PostFilterAccount], counts: [String: Int], allCount: Int?)
        -> [ArchiveFilterOption]
    {
        let known = allCount != nil
        let all = ArchiveFilterOption(code: nil, label: .localized(.Archive.all), count: allCount)
        return [all]
            + accounts.map { account in
                ArchiveFilterOption(
                    code: account.code,
                    label: account.isBilibili
                        ? .localized(DisplayCodeLabels.platform(.bilibili)) : .verbatim("@" + account.code),
                    logo: account.isBilibili ? .bilibili : .x,
                    count: known ? counts[account.code.lowercased()] ?? 0 : nil)
            }
    }
}
