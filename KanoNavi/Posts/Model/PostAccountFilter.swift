import KanoNaviComponents
import KanoNaviCore

/// The post timeline's account filter: the board's X accounts, then its
/// Bilibili accounts, each with its platform's logo and the timeline's count.
enum PostAccountFilter {
    /// The accounts from the dashboard's metadata, or, without a snapshot,
    /// the accounts the timeline counts, in their order. A handle is taken
    /// without the leading `@` the metadata may carry, as the API's
    /// `account` parameter takes it.
    static func accounts(meta: DashboardMeta?, counts: [String: Int]) -> [PostFilterAccount] {
        guard let meta else {
            return counts.keys.sorted().map { PostFilterAccount(code: $0, isBilibili: false) }
        }
        return meta.xAccounts.map { PostFilterAccount(code: handle($0), isBilibili: false) }
            + (meta.bilibiliAccounts ?? []).map { PostFilterAccount(code: $0, isBilibili: true) }
    }

    /// The filter's choices: all posts, then each account with the
    /// timeline's count, which the API keys by lowercase handle. Counts are
    /// `nil` before the timeline loads.
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

    private static func handle(_ account: String) -> String {
        account.hasPrefix("@") ? String(account.dropFirst()) : account
    }
}
