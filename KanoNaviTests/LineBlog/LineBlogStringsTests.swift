import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// The LineBlog table words every code, known or not, in every interface
/// language.
struct LineBlogStringsTests {
    private static let languages = ["en", "ja", "zh-Hans"]

    /// Every wording of an API code this feature shows, with a code this app
    /// does not know for each set.
    private static let codeLabels: [(name: String, label: LocalizedStringResource)] = [
        ("recovery stand-in", LineBlogRecoveryNote.text(for: .standIn)),
        ("recovery tweet", LineBlogRecoveryNote.text(for: .tweet)),
        ("recovery unknown", LineBlogRecoveryNote.text(for: .unknown("later-code"))),
        ("rating star", .LineBlog.ratingStars(3, 5)),
        ("rating face", .LineBlog.ratingFaces(3, 5)),
        ("rating unknown", .LineBlog.ratingPlain(3, 5)),
    ]

    @Test(arguments: codeLabels.map(\.name))
    func everyCodeIsWordedInAllThreeLanguages(name: String) throws {
        let label = try #require(Self.codeLabels.first { $0.name == name }?.label)
        let wordings = Self.languages.map { resolved(label, $0) }

        #expect(wordings.allSatisfy { $0.isEmpty == false })
        #expect(Set(wordings).count == Self.languages.count, "each language has its own wording: \(wordings)")
        #expect(wordings.allSatisfy { $0.contains("later-code") == false }, "a raw code is never shown")
    }

    @Test func anUnknownRecoveryCodeGetsANeutralNote() {
        #expect(
            resolved(LineBlogRecoveryNote.text(for: .unknown("later-code")), "en")
                == "Added after recovery")
    }

    @Test func tableResolvesInEachLanguage() {
        #expect(resolved(.LineBlog.title, "en") == "LINE BLOG Archive")
        #expect(resolved(.LineBlog.title, "ja") == "LINE BLOG アーカイブ")
        #expect(resolved(.LineBlog.title, "zh-Hans") == "LINE BLOG 存档")
        #expect(resolved(.LineBlog.machineTranslation, "ja") == "機械翻訳")
        #expect(resolved(.LineBlog.older, "ja") == "前の記事")
        #expect(resolved(.LineBlog.newer, "zh-Hans") == "较新的文章")
    }

    @Test func countsArePluralized() {
        #expect(resolved(.LineBlog.commentCount(1), "en") == "1 Comment")
        #expect(resolved(.LineBlog.commentCount(12), "en") == "12 Comments")
        #expect(resolved(.LineBlog.commentCount(12), "ja") == "コメント 12 件")
        #expect(resolved(.LineBlog.articleCount(1), "en") == "1 Article")
        #expect(resolved(.LineBlog.articleCount(5), "zh-Hans") == "5 篇")
        #expect(resolved(.LineBlog.titleWithCount("2019", 6), "en") == "2019 (6)")
    }

    @Test func neighboursAreNamedByAge() {
        #expect(resolved(LineBlogNeighborDirection.older.label, "en") == "Older Article")
        #expect(resolved(LineBlogNeighborDirection.newer.label, "en") == "Newer Article")
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
