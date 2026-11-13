import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// A comment's rating is drawn with its glyphs and its figures, and read as
/// a sentence.
struct LineBlogRatingDisplayTests {
    typealias Fixtures = LineBlogFixtures

    @Test(arguments: [(1, "★☆☆☆☆"), (4, "★★★★☆"), (5, "★★★★★")])
    func starsAreFilledUpToTheValue(value: Int, glyphs: String) throws {
        let display = try #require(LineBlogRatingDisplay(try Fixtures.rating(icon: "star", value: value)))

        #expect(display.glyphs == glyphs)
        #expect(display.figures == "\(value)/5")
    }

    @Test(arguments: [(1, "😣"), (3, "😐"), (5, "😊")])
    func aFaceRatingIsOneFace(value: Int, glyph: String) throws {
        let display = try #require(LineBlogRatingDisplay(try Fixtures.rating(icon: "face", value: value)))

        #expect(display.glyphs == glyph)
        #expect(display.figures == "\(value)/5")
    }

    @Test func anUnknownKindOfRatingShowsItsFiguresAlone() throws {
        let display = try #require(LineBlogRatingDisplay(try Fixtures.rating(icon: "heart", value: 2)))

        #expect(display.glyphs.isEmpty)
        #expect(display.figures == "2/5")
        #expect(resolved(display.label, "en") == "Rating: 2 of 5")
    }

    @Test(arguments: [0, 6, -1])
    func aValueOutsideTheScaleIsNotDrawn(value: Int) throws {
        #expect(LineBlogRatingDisplay(try Fixtures.rating(icon: "star", value: value)) == nil)
    }

    @Test func ratingIsReadAsASentenceInEachLanguage() throws {
        let stars = try #require(LineBlogRatingDisplay(try Fixtures.rating(icon: "star", value: 4)))
        let face = try #require(LineBlogRatingDisplay(try Fixtures.rating(icon: "face", value: 2)))

        #expect(resolved(stars.label, "en") == "Star rating: 4 of 5")
        #expect(resolved(stars.label, "ja") == "星の評価：5 点中 4 点")
        #expect(resolved(stars.label, "zh-Hans") == "星级评分：4 分，满分 5 分")
        #expect(resolved(face.label, "en") == "Face rating: 2 of 5")
        #expect(resolved(face.label, "ja") == "顔の評価：5 点中 2 点")
        #expect(resolved(face.label, "zh-Hans") == "表情评分：2 分，满分 5 分")
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
