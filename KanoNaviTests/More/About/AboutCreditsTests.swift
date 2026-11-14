import Testing

@testable import KanoNavi

@MainActor
struct AboutCreditsTests {
    @Test func listsTheModelsByTheirOfficialNames() {
        #expect(AboutCredits.models == ["Claude Opus 5.5", "Gemini 4 Carbon", "Claude Fable 5.2"])
    }
}
