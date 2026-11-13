import KanoNaviCore

/// The items of one Japan year in a Works list.
nonisolated struct WorksYearGroup<Item>: Identifiable {
    let year: Int
    var items: [Item]

    var id: Int { year }

    /// Groups `items` by the year of their Japan date, in `order`. Items of
    /// one date keep the collection's order when oldest comes first and the
    /// reverse of it when newest does, so the two orders mirror each other.
    static func groups(
        of items: [Item], order: WorksOrder, date: (Item) -> JapanDate
    ) -> [WorksYearGroup<Item>] {
        // A stable sort: the collection already lists its items by date.
        let oldestFirst = items.enumerated().sorted { lhs, rhs in
            let (left, right) = (date(lhs.element), date(rhs.element))
            return left == right ? lhs.offset < rhs.offset : left < right
        }.map(\.element)
        let ordered = order == .oldestFirst ? oldestFirst : oldestFirst.reversed()

        var groups: [WorksYearGroup<Item>] = []
        for item in ordered {
            let year = date(item).year
            if groups.last?.year == year {
                groups[groups.count - 1].items.append(item)
            } else {
                groups.append(WorksYearGroup(year: year, items: [item]))
            }
        }
        return groups
    }
}

extension WorksYearGroup: Equatable where Item: Equatable {}
extension WorksYearGroup: Sendable where Item: Sendable {}
