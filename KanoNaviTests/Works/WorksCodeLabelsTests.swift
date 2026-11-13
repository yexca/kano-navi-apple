import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// The Works codes in words: every known code has its own label in each
/// interface language, and a code the app does not know gets a neutral one.
struct WorksCodeLabelsTests {
    private static let languages = ["en", "ja", "zh-Hans"]

    /// Every label the catalog words for a code, known and fallback.
    private static var allLabels: [LocalizedStringResource] {
        let formats = ["album", "single", "ep", "doujin", "mystery"].map {
            WorksCodeLabels.format(WorksReleaseFormat(code: $0))
        }
        let roles = ["vocal", "lyrics", "composition", "voice", "guest", "mystery"].map {
            WorksCodeLabels.role(WorksParticipationRole(code: $0))
        }
        let forms = ["digital", "bonus", "drama", "cdr", "boxSet", "notForSale", "promo", "mystery"].map {
            WorksCodeLabels.form($0)
        }
        let credits = ["lyrics", "composition", "arrangement", "animation", "other", "mystery"].map {
            WorksCodeLabels.kanoCredit(WorksKanoCredit(code: $0))
        }
        let kinds = ["cover", "original", "mv", "project", "compilation", "game", "composition", "mystery"]
            .map {
                WorksCodeLabels.uploadKind(WorksUploadKind(code: $0))
            }
        let stores = (storeCodes + ["mystery"]).map { WorksCodeLabels.storePlatform($0) }
        let imageCredits = ["scan", "photo", "fan", "mystery"].flatMap { role in
            [credit(role, name: "Example"), credit(role, name: nil)].map(WorksCodeLabels.imageCredit)
        }
        let platforms = VideoPlatform.allCases.map(WorksCodeLabels.platform)
        let origins = ["auto", "operator", "mystery"].map {
            WorksCodeLabels.recentOrigin(WorksRecentOrigin(code: $0))
        }
        let facts = [WorksFact.Kind.label, .catalog, .price, .format, .packaging, .released, .jan, .event].map
        {
            WorksFactRow.title(for: $0)
        }
        let filters = [WorksCodeLabels.formatFilter("other"), WorksCodeLabels.uploadKindFilter("other")]
        return formats + roles + forms + credits + kinds + stores + imageCredits + platforms + origins + facts
            + filters
    }

    private static let storeCodes = [
        "smart_link", "apple_music", "spotify", "amazon_music", "line_music", "youtube_music", "awa",
        "itunes",
        "mora", "recochoku", "ototoy", "qq_music", "kugou", "label_page",
    ]

    private static func credit(_ role: String, name: String?) -> WorksImageCredit {
        let json: [String: Any] = ["role": role, "name": name ?? NSNull(), "url": NSNull()]
        do {
            return try WorksFixtures.decode(WorksImageCredit.self, json)
        } catch {
            preconditionFailure("The credit fixture does not match the model: \(error)")
        }
    }

    @Test(arguments: languages)
    func everyCodeLabelIsInTheCatalogInEachLanguage(language: String) throws {
        let table = try compiledTable(language)

        for label in Self.allLabels {
            #expect(table[label.key] != nil, "\(label.key) is missing in \(language)")
            #expect(resolved(label, language).isEmpty == false)
            #expect(resolved(label, language) != label.key)
        }
    }

    @Test func knownCodesHaveTheirOwnLabel() {
        #expect(resolved(WorksCodeLabels.format(.doujin), "en") == "Doujin")
        #expect(resolved(WorksCodeLabels.format(.single), "ja") == "シングル")
        #expect(resolved(WorksCodeLabels.role(.vocal), "zh-Hans") == "演唱")
        #expect(resolved(WorksCodeLabels.role(.voice), "en") == "Voice acting")
        #expect(resolved(WorksCodeLabels.form("notForSale"), "ja") == "非売品")
        #expect(resolved(WorksCodeLabels.form("boxSet"), "en") == "Box set")
        #expect(resolved(WorksCodeLabels.kanoCredit(.arrangement), "zh-Hans") == "编曲")
        #expect(resolved(WorksCodeLabels.uploadKind(.cover), "ja") == "歌ってみた")
        #expect(resolved(WorksCodeLabels.uploadKind(.game), "en") == "Game / project song")
        #expect(resolved(WorksCodeLabels.storePlatform("smart_link"), "en") == "All stores")
        #expect(resolved(WorksCodeLabels.storePlatform("qq_music"), "zh-Hans") == "QQ 音乐")
        #expect(resolved(WorksCodeLabels.platform(.niconico), "ja") == "niconico")
        #expect(resolved(WorksCodeLabels.recentOrigin(.operator), "en") == "Added by hand")
    }

    @Test func knownCodesOfASetAreWordedApart() {
        let formats = ["album", "single", "ep", "doujin"].map {
            resolved(WorksCodeLabels.format(WorksReleaseFormat(code: $0)), "en")
        }
        let stores = Self.storeCodes.map { resolved(WorksCodeLabels.storePlatform($0), "en") }
        let kinds = ["cover", "original", "mv", "project", "compilation", "game", "composition"].map {
            resolved(WorksCodeLabels.uploadKind(WorksUploadKind(code: $0)), "ja")
        }

        #expect(Set(formats).count == formats.count)
        #expect(Set(stores).count == stores.count)
        #expect(Set(kinds).count == kinds.count)
    }

    @Test(arguments: languages)
    func anUnknownCodeGetsANeutralLabelNeverTheCode(language: String) {
        let code = "mystery_code"
        let labels = [
            WorksCodeLabels.format(WorksReleaseFormat(code: code)),
            WorksCodeLabels.role(WorksParticipationRole(code: code)),
            WorksCodeLabels.form(code),
            WorksCodeLabels.kanoCredit(WorksKanoCredit(code: code)),
            WorksCodeLabels.uploadKind(WorksUploadKind(code: code)),
            WorksCodeLabels.storePlatform(code),
            WorksCodeLabels.imageCredit(Self.credit(code, name: nil)),
            WorksCodeLabels.recentOrigin(WorksRecentOrigin(code: code)),
        ]

        for label in labels {
            let text = resolved(label, language)
            #expect(text.isEmpty == false)
            #expect(text.contains("mystery") == false)
        }
    }

    @Test func unknownCodesShareTheSetsFallback() {
        #expect(WorksCodeLabels.form("mystery").key == WorksCodeLabels.form("another").key)
        #expect(WorksCodeLabels.storePlatform("mystery").key == WorksCodeLabels.storePlatform("").key)
        #expect(WorksCodeLabels.kanoCredit(.unknown("mystery")).key == WorksCodeLabels.kanoCredit(.other).key)
        #expect(WorksCodeLabels.formatFilter("album").key == WorksCodeLabels.format(.album).key)
        #expect(WorksCodeLabels.uploadKindFilter("mv").key == WorksCodeLabels.uploadKind(.mv).key)
    }

    @Test func imageCreditNamesTheContributorWhenTheRecordDoes() {
        #expect(
            resolved(WorksCodeLabels.imageCredit(Self.credit("scan", name: "Example")), "en")
                == "Scanned by Example")
        #expect(
            resolved(WorksCodeLabels.imageCredit(Self.credit("scan", name: "Example")), "ja")
                == "Example スキャン")
        #expect(
            resolved(WorksCodeLabels.imageCredit(Self.credit("photo", name: "Example")), "en")
                == "Photo from Example")
        #expect(
            resolved(WorksCodeLabels.imageCredit(Self.credit("fan", name: "Example")), "en") == "From a fan")
        #expect(resolved(WorksCodeLabels.imageCredit(Self.credit("scan", name: "")), "en") == "Scan")
        #expect(
            resolved(WorksCodeLabels.imageCredit(Self.credit("mystery", name: "Example")), "en")
                == "Credit: Example")
    }

    @Test func watchLinksNameThePlatformAndMarkMembersOnly() throws {
        let open = try #require(PlatformVideoLink(platform: .youtube, id: "abc"))
        let members = try #require(PlatformVideoLink(platform: .youtube, id: "def", isMembersOnly: true))

        #expect(resolved(WorksWatchLinks.name(for: open), "en") == "YouTube")
        #expect(resolved(WorksWatchLinks.name(for: members), "en").hasSuffix("Members only"))
        #expect(WorksWatchLinks.symbol(for: open) != WorksWatchLinks.symbol(for: members))
    }

    @Test func aGoneWatchLinkSaysSoInWords() throws {
        let link = try #require(PlatformVideoLink(platform: .youtube, id: "abc"))
        let gone = WorksUploadLink(link, isGone: true)
        let there = WorksUploadLink(link)

        #expect(resolved(WorksWatchLinks.title(for: there), "en") == "YouTube")
        #expect(resolved(WorksWatchLinks.title(for: gone), "en") == "YouTube · Unavailable")
        #expect(resolved(WorksWatchLinks.title(for: gone), "ja") == "YouTube · 視聴不可")
        #expect(resolved(WorksWatchLinks.title(for: gone), "zh-Hans") == "YouTube · 无法观看")
        #expect(
            resolved(WorksWatchLinks.spokenLabel(for: gone, title: "Song"), "en").contains(
                "no longer watchable"))
    }

    @Test func repeatedCodesAreListedOnce() throws {
        let work = try WorksFixtures.participation(
            id: "w", roles: ["vocal", "lyrics", "vocal", "mystery", "mystery"], forms: ["digital", "digital"])

        #expect(work.roles.uniqued() == [.vocal, .lyrics, .unknown("mystery")])
        #expect(work.forms.uniqued() == ["digital"])
        #expect([WorksKanoCredit.lyrics, .other, .lyrics].uniqued() == [.lyrics, .other])
    }

    @Test func lengthsAreSpokenInWords() {
        let english = Locale(identifier: "en_US")

        #expect(WorksDateFormat.spokenLength(seconds: 245, locale: english) == "4 minutes, 5 seconds")
        #expect(
            WorksDateFormat.spokenLength(seconds: 7265, locale: english) == "2 hours, 1 minute, 5 seconds")
        #expect(WorksDateFormat.spokenLength(seconds: nil, locale: english) == nil)
        #expect(WorksDateFormat.spokenLength(seconds: 0, locale: english) == nil)
        #expect(
            resolved(.Works.uploadLengthSpoken("4 minutes, 5 seconds"), "en")
                == "Length: 4 minutes, 5 seconds")
    }

    @Test func countsArePluralizedAndDatesCarryTheirYear() {
        #expect(resolved(.Works.trackCount(1), "en") == "1 Track")
        #expect(resolved(.Works.trackCount(10), "en") == "10 Tracks")
        #expect(resolved(.Works.fullTrackList(16), "ja") == "全収録曲 · 16 曲")
        #expect(resolved(.Works.summaryYears("2010", "2026"), "en") == "2010–2026")

        let date = JapanDate(year: 2020, month: 3, day: 4)
        #expect(WorksDateFormat.date(date, locale: Locale(identifier: "en_US")) == "Mar 4, 2020")
        #expect(WorksDateFormat.date(date, locale: Locale(identifier: "ja_JP")) == "2020年3月4日")
        #expect(WorksDateFormat.date(date, locale: Locale(identifier: "zh_CN")) == "2020年3月4日")
    }

    @Test(arguments: [(245, "4:05"), (7265, "2:01:05")])
    func lengthsReadAsThePlatformsShowThem(seconds: Int, expected: String) {
        #expect(WorksDateFormat.length(seconds: seconds) == expected)
    }

    @Test func anUnknownLengthIsNotShown() {
        #expect(WorksDateFormat.length(seconds: nil) == nil)
        #expect(WorksDateFormat.length(seconds: 0) == nil)
    }

    /// The Works table as the app bundle carries it for one language:
    /// plain strings and, where a language has plural forms, its plural rules.
    private func compiledTable(_ language: String) throws -> [String: Any] {
        var table: [String: Any] = [:]
        for kind in ["strings", "stringsdict"] {
            guard
                let url = Bundle.main.url(
                    forResource: "Works", withExtension: kind, subdirectory: nil, localization: language),
                let entries = NSDictionary(contentsOf: url) as? [String: Any]
            else { continue }
            table.merge(entries) { first, _ in first }
        }
        try #require(table.isEmpty == false, "No Works table for \(language) in the app bundle")
        return table
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
