import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// An article the archive does not have gets its own state.
struct LineBlogArticleFailureTests {
    @Test func unknownArticleIsNotFound() {
        #expect(LineBlogArticleFailure.isNotFound(APIError.http(status: 404)))
        #expect(LineBlogArticleFailure.isNotFound(RequestValidationError.invalidArticleID))
    }

    @Test func otherFailuresKeepTheirOwnReason() {
        #expect(LineBlogArticleFailure.isNotFound(APIError.http(status: 500)) == false)
        #expect(LineBlogArticleFailure.isNotFound(APIError.offline) == false)
        #expect(LineBlogArticleFailure.isNotFound(APIError.decoding("synthetic")) == false)
        #expect(LineBlogArticleFailure.isNotFound(RequestValidationError.invalidPage) == false)
        #expect(LineBlogArticleFailure.isNotFound(nil) == false)
    }
}
