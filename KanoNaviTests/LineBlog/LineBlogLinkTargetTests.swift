import Foundation
import Testing

@testable import KanoNavi

/// Links and cards open an archived article in the app, a web page outside,
/// or nothing.
struct LineBlogLinkTargetTests {
    @Test func articleNumberWinsOverTheAddress() {
        let target = LineBlogLinkTarget(
            href: URL(string: "https://blog.example.com/archives/2002.html"), articleID: "2002")

        #expect(target == .article(id: "2002"))
    }

    @Test(arguments: ["", "0123", "12a", "１２３", "../2002", "20 02"])
    func somethingThatIsNotAnArticleNumberFallsBackToTheAddress(articleID: String) {
        let href = URL(string: "https://blog.example.com/archives/2002.html")
        let target = LineBlogLinkTarget(href: href, articleID: articleID)

        #expect(target == href.map(LineBlogLinkTarget.outside))
    }

    @Test(arguments: ["http://example.com/page", "https://example.com/page?x=1#top", "HTTPS://example.com"])
    func webAddressOpensOutside(address: String) throws {
        let url = try #require(URL(string: address))

        #expect(LineBlogLinkTarget(href: url, articleID: nil) == .outside(url))
    }

    @Test(arguments: [
        "javascript:alert(1)", "mailto:someone@example.com", "/archives/2002.html", "tel:0000",
        "file:///etc/hosts",
        "https:///nohost", "kanonavi://schedule",
    ])
    func anythingElseIsNotALink(address: String) throws {
        let url = try #require(URL(string: address))

        #expect(LineBlogLinkTarget(href: url, articleID: nil) == nil)
        #expect(LineBlogLinkTarget(opened: url) == nil)
    }

    @Test func noAddressAndNoArticleIsNotALink() {
        #expect(LineBlogLinkTarget(href: nil, articleID: nil) == nil)
    }

    @Test(arguments: [
        LineBlogLinkTarget.article(id: "13162309"),
        LineBlogLinkTarget.outside(URL(string: "https://example.com/page?x=1")!),
    ])
    func addressCarriedInTextReadsBackAsTheSameTarget(target: LineBlogLinkTarget) {
        #expect(LineBlogLinkTarget(opened: target.url) == target)
    }

    @Test func articleAddressIsNotAWebAddress() {
        let url = LineBlogLinkTarget.article(id: "2002").url

        #expect(LineBlogLinkTarget.outsideURL(url) == nil, "an in-app link is never handed to the system")
    }

    @Test(arguments: [
        "kanonavi-lineblog-article:", "kanonavi-lineblog-article:abc", "kanonavi-lineblog-article:012",
    ])
    func forgedArticleAddressIsDropped(address: String) throws {
        let url = try #require(URL(string: address))

        #expect(LineBlogLinkTarget(opened: url) == nil)
    }
}
