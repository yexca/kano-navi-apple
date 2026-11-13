import KanoNaviCore

/// The collection's uploads as the Uploads screen lists them: joined with
/// the stored covers and videos by upload ID, searched, narrowed to a kind
/// and grouped by Japan year.
nonisolated struct WorksUploadCatalog: Equatable, Sendable {
    /// The kinds with a choice of their own, in the order shown.
    static let filter = WorksCodeFilter(
        known: ["cover", "original", "mv", "project", "compilation", "game", "composition"])

    /// The uploads in the collection's order, oldest first.
    let items: [WorksUploadItem]

    /// Joins the list with the stored data; `stored` is `nil` while that
    /// read has no value, and the list shows without it.
    init(list: WorksUploadListResponse, stored: WorksUploadsResponse?) {
        items = list.uploads.map { WorksUploadItem(entry: $0, state: stored?.uploads[$0.id]) }
    }

    private init(items: [WorksUploadItem]) {
        self.items = items
    }

    /// Whether the rows shown for `kind` keep room for a cover: only when
    /// one of those rows has a cover, so a list without stored data, or a
    /// kind without any, is not a column of empty frames.
    func showsCovers(kind: String?) -> Bool {
        shown(kind: kind).contains { $0.cover != nil }
    }

    /// The uploads that answer a search; all of them for an empty query.
    func searching(_ query: String) -> WorksUploadCatalog {
        WorksUploadCatalog(items: items.filter { $0.matches(query: query) })
    }

    /// The filter's choices: all uploads, then each kind that has any.
    var options: [ArchiveFilterOption] {
        let all = ArchiveFilterOption(code: nil, label: .localized(.Works.filterAll), count: items.count)
        let kinds = Self.filter.counts(of: items.map(\.entry.kind.rawValue)).map { entry in
            ArchiveFilterOption(
                code: entry.code, label: .localized(WorksCodeLabels.uploadKindFilter(entry.code)),
                count: entry.count)
        }
        return [all] + kinds
    }

    /// The uploads of `kind` (`nil` for all) by year, in `order`.
    func groups(kind: String?, order: WorksOrder) -> [WorksYearGroup<WorksUploadItem>] {
        WorksYearGroup.groups(of: shown(kind: kind), order: order, date: \.entry.date)
    }

    /// The uploads of `kind` (`nil` for all) in the collection's order.
    private func shown(kind: String?) -> [WorksUploadItem] {
        items.filter { Self.filter.matches($0.entry.kind.rawValue, selection: kind) }
    }
}
