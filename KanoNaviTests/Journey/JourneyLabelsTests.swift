import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// Codes map to their wording, and unknown codes to a neutral label.
struct JourneyLabelsTests {
    @Test(arguments: [
        ("honey", JourneyTone.honey), ("leaf", .leaf), ("berry", .berry), ("lavender", .lavender),
        ("sky", .sky),
        ("mint", .neutral), ("", .neutral),
    ])
    func toneCodes(_ code: String, _ tone: JourneyTone) {
        #expect(JourneyTone(code: code) == tone)
    }

    @Test func unknownKindIsANeutralMilestone() {
        #expect(JourneyKind(code: "hologram") == .other)
        #expect(JourneyKind(code: "model3d") == .model3d)
        #expect(english(JourneyKind(code: "hologram").label) == "Milestone")
    }

    @Test func everyKindHasItsOwnWordingAndSymbol() {
        let labels = JourneyKind.allCases.map { english($0.label) }
        #expect(Set(labels).count == JourneyKind.allCases.count)
        #expect(JourneyKind.allCases.allSatisfy { $0.systemImage.isEmpty == false })
    }

    @Test func unknownCodesGetNeutralLabels() {
        #expect(english(JourneyLabels.link(.unknown("blog"))) == "Related page")
        #expect(english(JourneyLabels.category(.unknown("sticker"))) == "Other images")
        #expect(english(JourneyLabels.dateKind(.unknown("print"))) == "Date")
        #expect(english(JourneyLabels.sourceKind(.unknown("museum"))) == "Other source")
    }

    @Test func knownCodesAreWorded() {
        #expect(english(JourneyLabels.link(.cancelledRelease)) == "CD cancellation notice")
        #expect(english(JourneyLabels.category(.frame)) == "Video frames")
        #expect(english(JourneyLabels.dateKind(.release)) == "Release / distribution date")
        #expect(
            english(JourneyLabels.sourceKind(.thirdPartyCover)) == "Release cover from a third-party archive")
    }

    @Test func unknownOrMissingNoteShowsNothing() {
        #expect(JourneyLabels.note(nil) == nil)
        #expect(JourneyLabels.note("newNote") == nil)
        #expect(JourneyLabels.noteCodes.allSatisfy { JourneyLabels.note($0) != nil })
    }

    @Test func coverCreditWordsTheRole() throws {
        let scan = try JourneyFixtures.decode(
            WorksImageCredit.self, ["role": "scan", "name": "Example Scanner"])
        let fan = try JourneyFixtures.decode(WorksImageCredit.self, ["role": "fan", "name": NSNull()])
        let nameless = try JourneyFixtures.decode(WorksImageCredit.self, ["role": "scan", "name": NSNull()])
        let unknown = try JourneyFixtures.decode(
            WorksImageCredit.self, ["role": "loan", "name": "Example Lender"])
        #expect(try english(#require(JourneyLabels.coverCredit(scan))) == "Scanned by Example Scanner")
        #expect(try english(#require(JourneyLabels.coverCredit(fan))) == "From a fan")
        #expect(JourneyLabels.coverCredit(nameless) == nil)
        #expect(try english(#require(JourneyLabels.coverCredit(unknown))) == "Credit: Example Lender")
        #expect(JourneyLabels.coverCredit(nil) == nil)
    }

    @Test(arguments: [
        ("https://www.example.com/page", "example.com"), ("https://shop.example.com/a", "shop.example.com"),
    ])
    func hostNamesTheSite(_ address: String, _ host: String) throws {
        #expect(JourneyLabels.host(of: try #require(URL(string: address))) == host)
    }

    private func english(_ resource: LocalizedStringResource) -> String {
        var resource = resource
        resource.locale = Locale(identifier: "en")
        return String(localized: resource)
    }
}
