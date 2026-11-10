import Foundation
import KanoNaviCore
import Testing

@testable import KanoNaviComponents

struct EventPresentationTests {
    @Test(arguments: [
        ("automatic", false, false),
        ("manual", false, true),
        ("automatic", true, true),
    ])
    func confirmedMeansManualOrLocked(provenance: String, locked: Bool, confirmed: Bool) throws {
        let event = try SyntheticEvent.make(provenance: provenance, manualLocked: locked)

        #expect(event.isConfirmed == confirmed)
    }

    @Test func membersOnlyFollowsTheTypeCode() throws {
        #expect(try SyntheticEvent.make(typeCode: "member").isMembersOnly)
        #expect(try SyntheticEvent.make(typeCode: "stream").isMembersOnly == false)
    }

    @Test func stateComesFromTheView() throws {
        #expect(try SyntheticEvent.make(state: "cancelled").isCancelled)
        #expect(try SyntheticEvent.make(state: "cancellation_review").displayState == .cancellationReview)
        #expect(try SyntheticEvent.make(includesView: false).displayState == .unknown(""))
    }

    @Test func saleKeepsBothCalendarEntriesInServerOrder() throws {
        let event = try SyntheticEvent.make(
            typeCode: "sale",
            calendarEntries: [
                [
                    "saleMark": "opens", "startsOn": "2026-11-10", "startsAt": "2026-11-10T03:00:00Z",
                    "timePrecision": "exact",
                ],
                [
                    "saleMark": "closes", "startsOn": "2026-11-12", "startsAt": "2026-11-12T09:00:00Z",
                    "timePrecision": "exact",
                ],
            ])

        #expect(event.displayCalendarEntries.map(\.saleMark) == [.opens, .closes])
        #expect(event.displayCalendarEntries.map(\.startsOn.rawValue) == ["2026-11-10", "2026-11-12"])
    }

    @Test func recordWithoutAViewFallsBackToItsStart() throws {
        let event = try SyntheticEvent.make(startsOn: "2026-11-12", includesView: false)

        #expect(event.displayCalendarEntries.map(\.startsOn.rawValue) == ["2026-11-12"])
    }

    @Test func titleUsesTheContentLanguageTranslation() throws {
        let event = try SyntheticEvent.make(
            title: "原題",
            translations: ["en": ["text": "English title", "origin": "machine"]])

        let english = event.resolvedTitle(preference: .en, interfaceLocale: Locale(identifier: "ja"))
        let system = event.resolvedTitle(preference: .system, interfaceLocale: Locale(identifier: "ja"))

        #expect(english.text == "English title")
        #expect(english.isTranslation)
        #expect(english.origin == .machine)
        #expect(system.text == "原題")
        #expect(system.isTranslation == false)
    }
}
