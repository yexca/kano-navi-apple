import Foundation

/// Which schedule additions and changes raise notifications.
public struct ScheduleNotificationSettings: Codable, Equatable, Sendable {
    public var newEvents: Bool
    public var cancellationsAndChanges: Bool
    public var confirmedOnly: Bool
    public var categories: Set<ScheduleNotificationCategory>

    public init(
        newEvents: Bool = true,
        cancellationsAndChanges: Bool = true,
        confirmedOnly: Bool = false,
        categories: Set<ScheduleNotificationCategory> = Set(ScheduleNotificationCategory.allCases)
    ) {
        self.newEvents = newEvents
        self.cancellationsAndChanges = cancellationsAndChanges
        self.confirmedOnly = confirmedOnly
        self.categories = categories
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        newEvents = try container.decodeIfPresent(Bool.self, forKey: .newEvents) ?? true
        cancellationsAndChanges =
            try container.decodeIfPresent(Bool.self, forKey: .cancellationsAndChanges) ?? true
        confirmedOnly = try container.decodeIfPresent(Bool.self, forKey: .confirmedOnly) ?? false
        categories =
            try container.decodeIfPresent(Set<ScheduleNotificationCategory>.self, forKey: .categories)
            ?? Set(ScheduleNotificationCategory.allCases)
    }

    public var hasAnyEnabled: Bool {
        !categories.isEmpty && (newEvents || cancellationsAndChanges)
    }

    public var includesStreams: Bool {
        get { categories.contains(.stream) }
        set { setCategory(.stream, enabled: newValue) }
    }

    public var includesEvents: Bool {
        get { categories.contains(.event) }
        set { setCategory(.event, enabled: newValue) }
    }

    public var includesReleases: Bool {
        get { categories.contains(.release) }
        set { setCategory(.release, enabled: newValue) }
    }

    public var includesSales: Bool {
        get { categories.contains(.sale) }
        set { setCategory(.sale, enabled: newValue) }
    }

    private mutating func setCategory(_ category: ScheduleNotificationCategory, enabled: Bool) {
        if enabled {
            categories.insert(category)
        } else {
            categories.remove(category)
        }
    }
}
