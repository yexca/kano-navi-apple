import Foundation
import Testing

@testable import KanoNaviCore

struct PostsRequestTests {
    private static let november30 = JapanDate(year: 2026, month: 11, day: 30)

    @Test func timelineWithoutUntilReadsTheNewestPosts() throws {
        let request = PostsRequest(page: 1, pageSize: 50, account: "kano_example")

        try request.validate()
        #expect(request.path == "/api/posts")
        #expect(
            request.queryItems == [
                URLQueryItem(name: "page", value: "1"), URLQueryItem(name: "pageSize", value: "50"),
                URLQueryItem(name: "account", value: "kano_example"),
            ])
    }

    @Test func timelineWithUntilReadsOnOrBeforeThatDate() throws {
        let request = PostsRequest(until: Self.november30, page: 3, pageSize: 50)

        try request.validate()
        #expect(
            request.queryItems == [
                URLQueryItem(name: "until", value: "2026-11-30"), URLQueryItem(name: "page", value: "3"),
                URLQueryItem(name: "pageSize", value: "50"),
            ])
    }

    @Test func rangeStaysValid() throws {
        let request = PostsRequest(
            from: JapanDate(year: 2026, month: 11, day: 1), to: Self.november30, page: 2, pageSize: 20)

        try request.validate()
        #expect(request.queryItems.map(\.name) == ["from", "to", "page", "pageSize"])
    }

    @Test func untilWithARangeIsRejected() {
        let request = PostsRequest(
            from: JapanDate(year: 2026, month: 11, day: 1), to: Self.november30, until: Self.november30)

        #expect(throws: RequestValidationError.invalidDateRange) {
            try request.validate()
        }
    }

    @Test func untilWithHalfARangeIsRejected() {
        #expect(throws: RequestValidationError.invalidDateRange) {
            try PostsRequest(from: Self.november30, until: Self.november30).validate()
        }
        #expect(throws: RequestValidationError.invalidDateRange) {
            try PostsRequest(to: Self.november30, until: Self.november30).validate()
        }
    }

    @Test(arguments: [0, 51])
    func pageSizeOutsideTheAPIsLimitIsRejected(pageSize: Int) {
        #expect(throws: RequestValidationError.invalidPageSize) {
            try PostsRequest(pageSize: pageSize).validate()
        }
    }
}
