import Foundation
import Testing

@testable import KanoNavi

/// Running text joins, trims and reports its content.
struct LineBlogRichTextTests {
    private let target = LineBlogLinkTarget.article(id: "2002")
    private let pictograph = LineBlogPictograph(source: LineBlogFixtures.source("smile.png"), alt: "笑顔")

    @Test func textWithTheSameLinkJoinsAndEmptyTextIsDropped() {
        let text = LineBlogRichText(runs: [
            .text("あ", link: nil), .text("", link: target), .text("い", link: nil), .text("う", link: target),
            .text("え", link: target), .pictograph(pictograph, link: nil), .text("お", link: nil),
        ])

        #expect(
            text.runs == [
                .text("あい", link: nil), .text("うえ", link: target), .pictograph(pictograph, link: nil),
                .text("お", link: nil),
            ])
    }

    @Test func trimmingRemovesLineBreaksAndSpacesAtTheEndsOnly() {
        let text = LineBlogRichText(runs: [.text("\n  一行目\n二行目 \n", link: nil)])

        #expect(text.trimmed().runs == [.text("一行目\n二行目", link: nil)])
    }

    @Test func trimmingKeepsAFullWidthIndent() {
        let text = LineBlogRichText(runs: [.text("\n　字下げ", link: nil)])

        #expect(text.trimmed().runs == [.text("　字下げ", link: nil)])
    }

    @Test func trimmingStopsAtAPictograph() {
        let text = LineBlogRichText(runs: [.pictograph(pictograph, link: nil), .text(" 本文\n", link: nil)])

        #expect(text.trimmed().runs == [.pictograph(pictograph, link: nil), .text(" 本文", link: nil)])
    }

    @Test func blankMeansNothingToRead() {
        #expect(LineBlogRichText().isBlank)
        #expect(LineBlogRichText(runs: [.text(" \n　", link: nil)]).isBlank)
        #expect(LineBlogRichText(runs: [.pictograph(pictograph, link: nil)]).isBlank == false)
        #expect(LineBlogRichText(runs: [.text("あ", link: nil)]).isBlank == false)
    }

    @Test func aPictographInsideALinkIsKnown() {
        let lost = LineBlogPictograph(source: nil, alt: "音符")

        #expect(LineBlogRichText(runs: [.pictograph(pictograph, link: target)]).hasLinkedPictograph)
        #expect(LineBlogRichText(runs: [.pictograph(pictograph, link: nil)]).hasLinkedPictograph == false)
        #expect(LineBlogRichText(runs: [.text("あ", link: target)]).hasLinkedPictograph == false)
        #expect(
            LineBlogRichText(runs: [.pictograph(lost, link: target)]).hasLinkedPictograph == false,
            "a pictograph without a file is drawn as its linked description")
    }

    @Test func plainTextReadsAPictographAsItsDescription() {
        let silent = LineBlogPictograph(source: LineBlogFixtures.source("star.png"), alt: nil)
        let text = LineBlogRichText(runs: [
            .text("楽しい", link: nil), .pictograph(pictograph, link: nil), .pictograph(silent, link: nil),
        ])

        #expect(text.plainText == "楽しい笑顔")
        #expect(text.pictographSources.map(\.url.lastPathComponent) == ["smile.png", "star.png"])
    }
}
