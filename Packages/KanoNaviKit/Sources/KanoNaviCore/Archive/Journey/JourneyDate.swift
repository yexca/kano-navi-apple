import Foundation

/// A Journey milestone date as stored: `YYYY`, `YYYY-MM` or `YYYY-MM-DD`.
///
/// Only the known part is kept; a year or a month is never narrowed to a
/// guessed day. Dates order by year, then month, then day, and a less precise
/// date comes before a more precise one in the same period (`2016` <
/// `2016-01` < `2016-01-01`), as their text sorts.
public struct JourneyDate: Codable, Hashable, Comparable, Sendable, CustomStringConvertible {
    public let year: Int
    /// The month (1–12), or `nil` when only the year is known.
    public let month: Int?
    /// The day of the month, or `nil` when only the year or the month is known.
    public let day: Int?

    /// Parses `YYYY`, `YYYY-MM` or `YYYY-MM-DD`; `nil` for anything else,
    /// including an impossible day such as `2023-02-30`.
    public init?(rawValue: String) {
        let parts = rawValue.split(separator: "-", omittingEmptySubsequences: false)
        guard (1...3).contains(parts.count), parts[0].count == 4,
            parts.allSatisfy({ $0.allSatisfy(\.isASCII) && $0.allSatisfy(\.isNumber) }),
            let year = Int(parts[0])
        else { return nil }
        var month: Int?
        var day: Int?
        if parts.count >= 2 {
            guard parts[1].count == 2, let value = Int(parts[1]), (1...12).contains(value) else { return nil }
            month = value
        }
        if parts.count == 3 {
            guard parts[2].count == 2, JapanDate(rawValue: rawValue) != nil, let value = Int(parts[2]) else {
                return nil
            }
            day = value
        }
        self.year = year
        self.month = month
        self.day = day
    }

    /// A day-precision date.
    public init(_ date: JapanDate) {
        year = date.year
        month = date.month
        day = date.day
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let date = JourneyDate(rawValue: value) else {
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "Invalid Journey date \(value)")
        }
        self = date
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    /// The part of the date that is known.
    public var precision: JourneyDatePrecision {
        if day != nil { return .day }
        if month != nil { return .month }
        return .year
    }

    /// The date as stored, such as `2016`, `2016-09` or `2016-09-07`.
    public var rawValue: String {
        var text = String(format: "%04d", year)
        if let month { text += String(format: "-%02d", month) }
        if let day { text += String(format: "-%02d", day) }
        return text
    }

    public var description: String { rawValue }

    /// The Japan date of a day-precision date; `nil` for a year or a month.
    public var japanDate: JapanDate? {
        guard let month, let day else { return nil }
        return JapanDate(year: year, month: month, day: day)
    }

    public static func < (lhs: JourneyDate, rhs: JourneyDate) -> Bool {
        (lhs.year, lhs.month ?? 0, lhs.day ?? 0) < (rhs.year, rhs.month ?? 0, rhs.day ?? 0)
    }
}

/// How much of a `JourneyDate` is known; the API's `datePrecision`.
public enum JourneyDatePrecision: String, Codable, Hashable, Sendable, CaseIterable {
    case year
    case month
    case day
}
