import Foundation

/// A calendar date in Japan, independent of an instant at midnight.
public struct JapanDate: Codable, Equatable, Hashable, Comparable, Sendable, CustomStringConvertible {
    public let rawValue: String
    public var description: String { rawValue }

    public init?(rawValue: String) {
        let parts = rawValue.split(separator: "-")
        guard parts.count == 3, parts[0].count == 4, parts[1].count == 2, parts[2].count == 2,
              let month = Int(parts[1]), let day = Int(parts[2]), (1...12).contains(month), (1...31).contains(day)
        else { return nil }
        let canonical = String(rawValue)
        let formatter = DateFormatter(); formatter.calendar = Calendar(identifier: .gregorian); formatter.locale = Locale(identifier: "en_US_POSIX"); formatter.timeZone = Self.timeZone; formatter.dateFormat = "yyyy-MM-dd"
        guard formatter.date(from: canonical) != nil else { return nil }
        self.rawValue = canonical
    }

    public init(year: Int, month: Int, day: Int) {
        let raw = String(format: "%04d-%02d-%02d", year, month, day)
        guard let value = JapanDate(rawValue: raw) else { preconditionFailure("Invalid Japan date") }
        self = value
    }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        guard let date = JapanDate(rawValue: value) else { throw DecodingError.dataCorruptedError(in: try decoder.singleValueContainer(), debugDescription: "Invalid Japan date") }
        self = date
    }

    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }

    public static let timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone(secondsFromGMT: 9 * 60 * 60) ?? .gmt
    public static var today: JapanDate { date(from: Date()) }
    public static func today(at instant: Date) -> JapanDate { date(from: instant) }

    public static func date(from instant: Date) -> JapanDate {
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = timeZone; calendar.locale = Locale(identifier: "en_US_POSIX")
        let components = calendar.dateComponents([.year, .month, .day], from: instant)
        return JapanDate(year: components.year ?? 1970, month: components.month ?? 1, day: components.day ?? 1)
    }

    public func addingDays(_ days: Int) -> JapanDate {
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = Self.timeZone
        let instant = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date(timeIntervalSince1970: 0)
        let moved = calendar.date(byAdding: .day, value: days, to: instant) ?? instant
        return Self.date(from: moved)
    }

    public func adding(_ days: Int) -> JapanDate { addingDays(days) }

    public var year: Int { Int(rawValue.prefix(4)) ?? 0 }
    public var month: Int { Int(rawValue.dropFirst(5).prefix(2)) ?? 0 }
    public var day: Int { Int(rawValue.suffix(2)) ?? 0 }

    /// The Monday beginning the week containing this date.
    public var weekStartMonday: JapanDate {
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = Self.timeZone; calendar.firstWeekday = 2; calendar.minimumDaysInFirstWeek = 1
        let instant = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date(timeIntervalSince1970: 0)
        let weekday = calendar.component(.weekday, from: instant)
        let offset = (weekday + 5) % 7
        return addingDays(-offset)
    }

    /// The 42 dates in a Monday-first month grid.
    public var monthGrid: [JapanDate] {
        let first = JapanDate(year: year, month: month, day: 1).weekStartMonday
        return (0..<42).map { first.addingDays($0) }
    }

    public static func < (lhs: JapanDate, rhs: JapanDate) -> Bool { lhs.rawValue < rhs.rawValue }
}

public enum JapanTime {
    public static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = JapanDate.timeZone; calendar.locale = Locale(identifier: "en_US_POSIX"); calendar.firstWeekday = 2; calendar.minimumDaysInFirstWeek = 1; return calendar
    }()

    public static func dateStyle(locale: Locale = .current) -> Date.FormatStyle {
        var style = Date.FormatStyle(date: .numeric, time: .omitted).locale(locale); style.timeZone = JapanDate.timeZone; return style
    }

    public static func dateTimeStyle(locale: Locale = .current) -> Date.FormatStyle {
        var style = Date.FormatStyle(date: .abbreviated, time: .shortened).locale(locale); style.timeZone = JapanDate.timeZone; return style
    }
}
