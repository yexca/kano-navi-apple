import Foundation
import Testing

@testable import KanoNaviCore

struct JourneyDateTests {
    @Test(arguments: [
        ("2010", JourneyDatePrecision.year, 2010, Int?.none, Int?.none),
        ("2012-08", .month, 2012, 8, nil),
        ("2016-09-07", .day, 2016, 9, 7),
    ])
    func keepsTheStoredPrecision(
        raw: String, precision: JourneyDatePrecision, year: Int, month: Int?, day: Int?
    )
        throws
    {
        let date = try #require(JourneyDate(rawValue: raw))
        #expect(date.precision == precision)
        #expect(date.year == year)
        #expect(date.month == month)
        #expect(date.day == day)
        #expect(date.rawValue == raw)
    }

    @Test func onlyADayPrecisionDateHasAJapanDate() throws {
        #expect(JourneyDate(rawValue: "2016-09-07")?.japanDate == JapanDate(year: 2016, month: 9, day: 7))
        #expect(JourneyDate(rawValue: "2016-09")?.japanDate == nil)
        #expect(JourneyDate(rawValue: "2016")?.japanDate == nil)
    }

    @Test(arguments: ["", "16", "2016-9", "2016-13", "2016-02-30", "2016-09-07-01", "2016/09", "２０１６"])
    func rejectsOtherShapes(raw: String) {
        #expect(JourneyDate(rawValue: raw) == nil)
    }

    @Test func ordersByYearMonthDayWithLessPreciseFirst() throws {
        let raws = ["2016-09-07", "2017", "2016", "2016-09", "2015-12-31", "2016-01"]
        let sorted = raws.compactMap(JourneyDate.init(rawValue:)).sorted().map(\.rawValue)
        #expect(sorted == ["2015-12-31", "2016", "2016-01", "2016-09", "2016-09-07", "2017"])
    }

    @Test func roundTripsThroughJSON() throws {
        let date = try #require(JourneyDate(rawValue: "2012-08"))
        let data = try JSONEncoder.kanoNavi().encode([date])
        #expect(String(decoding: data, as: UTF8.self) == #"["2012-08"]"#)
        #expect(try JSONDecoder.kanoNavi().decode([JourneyDate].self, from: data) == [date])
    }
}
