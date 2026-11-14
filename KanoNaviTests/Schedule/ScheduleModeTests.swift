import Foundation
import SwiftUI
import Testing

@testable import KanoNavi

/// The mode is kept in user defaults, starts as List, and caps each day's
/// marks with "+n".
@MainActor
final class ScheduleModeTests {
    private let defaults: UserDefaults
    private let suiteName = "ScheduleModeTests.\(UUID().uuidString)"

    init() throws {
        defaults = try #require(UserDefaults(suiteName: suiteName))
    }

    deinit {
        UserDefaults().removePersistentDomain(forName: suiteName)
    }

    private var storedMode: AppStorage<ScheduleMode> {
        AppStorage(wrappedValue: ScheduleMode.defaultMode, AppSettings.scheduleModeKey, store: defaults)
    }

    @Test func startsInListWhenNothingIsStored() {
        #expect(ScheduleMode.defaultMode == .list)
        #expect(storedMode.wrappedValue == .list)
    }

    @Test func remembersTheChosenMode() {
        storedMode.wrappedValue = .details

        #expect(defaults.string(forKey: AppSettings.scheduleModeKey) == "details")
        #expect(storedMode.wrappedValue == .details)
    }

    @Test func unknownStoredValueFallsBackToList() {
        defaults.set("agenda", forKey: AppSettings.scheduleModeKey)

        #expect(storedMode.wrappedValue == .list)
    }

    @Test(arguments: [
        (ScheduleMode.compact, 4, 4, 0), (.compact, 5, 3, 2), (.stacked, 0, 0, 0), (.stacked, 9, 3, 6),
        (.details, 3, 3, 0), (.details, 4, 2, 2),
    ])
    func dayShowsWhatFitsAndFoldsTheRestIntoMore(
        _ mode: ScheduleMode, _ count: Int, _ shown: Int, _ more: Int
    ) {
        let marks = mode.marks(forEntryCount: count)

        #expect(marks.shown == shown)
        #expect(marks.more == more)
    }

    @Test func narrowCellGivesUpDotsBeforeTheCount() {
        let marks = ScheduleMode.marks(forEntryCount: 5, capacity: 2)

        #expect(marks.shown == 1)
        #expect(marks.more == 4)
        #expect(ScheduleMode.marks(forEntryCount: 3, capacity: 1).shown == 0)
    }
}
