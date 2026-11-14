import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct ScheduleModelTests {
    private let november = JapanDate(year: 2026, month: 11, day: 1)
    private let december = JapanDate(year: 2026, month: 12, day: 1)

    private func model(_ stub: StubMonthLoader) -> ScheduleModel {
        ScheduleModel(loader: { month in try await stub.load(month) }, today: { ScheduleFixtures.today })
    }

    @Test func startsOnTodayInAMondayFirstGrid() {
        let model = model(StubMonthLoader([:]))

        #expect(model.displayedMonth == november)
        #expect(model.selectedDate == ScheduleFixtures.today)
        #expect(model.gridDates.count == 42)
        #expect(model.gridDates.first == JapanDate(year: 2026, month: 10, day: 26))
    }

    @Test func loadedMonthGivesCountsAndTheDaysEntries() async throws {
        let timed = try ScheduleFixtures.event(
            id: "timed", startsOn: "2026-11-10", startsAt: "2026-11-10T12:00:00Z")
        let early = try ScheduleFixtures.event(
            id: "early", startsOn: "2026-11-10", startsAt: "2026-11-10T01:00:00Z")
        let dateOnly = try ScheduleFixtures.event(id: "date-only", startsOn: "2026-11-10")
        let month = ScheduleFixtures.month(
            containing: november, events: [timed, early, dateOnly], dayCounts: [ScheduleFixtures.today: 3])
        let model = model(StubMonthLoader([november: [.success(month)]]))

        await model.loadIfNeeded()

        #expect(model.count(on: ScheduleFixtures.today) == 3)
        #expect(model.count(on: JapanDate(year: 2026, month: 11, day: 11)) == 0)
        #expect(model.entries(on: ScheduleFixtures.today).map(\.event.id) == ["date-only", "early", "timed"])
    }

    @Test func saleAppearsWhereItOpensAndWhereItCloses() async throws {
        let sale = try ScheduleFixtures.event(
            id: "sale", startsOn: "2026-11-10", startsAt: "2026-11-10T03:00:00Z", typeCode: "sale",
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
        let model = model(
            StubMonthLoader([
                november: [.success(ScheduleFixtures.month(containing: november, events: [sale]))]
            ]))

        await model.loadIfNeeded()

        #expect(model.entries(on: ScheduleFixtures.today).map(\.entry.saleMark) == [.opens])
        #expect(
            model.entries(on: JapanDate(year: 2026, month: 11, day: 12)).map(\.entry.saleMark) == [.closes])
        #expect(model.entries(on: JapanDate(year: 2026, month: 11, day: 11)).isEmpty)
    }

    @Test func failedRefreshKeepsTheLastGoodMonth() async throws {
        let event = try ScheduleFixtures.event(id: "kept", startsOn: "2026-11-10")
        let good = ScheduleFixtures.month(containing: november, events: [event])
        let model = model(
            StubMonthLoader([november: [.success(good), .failure(.http(status: 503)), .success(good)]]))

        await model.loadIfNeeded()
        await model.refresh()

        #expect(model.month == good)
        #expect(model.failure as? APIError == .http(status: 503))
        #expect(model.entries(on: ScheduleFixtures.today).map(\.event.id) == ["kept"])

        await model.refresh()

        #expect(model.failure == nil)
    }

    @Test func failedFirstLoadRecordsTheFailureWithoutData() async {
        let model = model(StubMonthLoader([:]))

        await model.loadIfNeeded()

        #expect(model.month == nil)
        #expect(model.failure as? APIError == .offline)
        #expect(model.gridDates.count == 42)
    }

    @Test func failuresSayWhetherAMonthIsStillOnScreen() async {
        let good = ScheduleFixtures.month(containing: november, events: [])
        let failing = model(StubMonthLoader([:]))
        let reloading = model(StubMonthLoader([november: [.success(good), .failure(.offline)]]))

        await failing.loadIfNeeded()
        await reloading.loadIfNeeded()
        #expect(reloading.notice == nil)
        await reloading.refresh()

        #expect(failing.notice == .loadFailed)
        #expect(reloading.notice == .updateFailed)
    }

    @Test func cachedMonthIsShownWithItsFetchTimeUntilAFreshRead() async throws {
        let event = try ScheduleFixtures.event(id: "saved", startsOn: "2026-11-10")
        let fetchedAt = Date(timeIntervalSince1970: 1_794_280_000)
        let saved = ScheduleFixtures.month(
            containing: november, events: [event], dayCounts: [ScheduleFixtures.today: 1], isStale: true,
            fetchedAt: fetchedAt)
        let fresh = ScheduleFixtures.month(
            containing: november, events: [event], dayCounts: [ScheduleFixtures.today: 1])
        let model = model(StubMonthLoader([november: [.success(saved), .success(fresh)]]))

        await model.loadIfNeeded()

        #expect(model.notice == .saved(fetchedAt: fetchedAt))
        #expect(model.count(on: ScheduleFixtures.today) == 1)
        #expect(model.entries(on: ScheduleFixtures.today).map(\.event.id) == ["saved"])

        await model.refresh()

        #expect(model.notice == nil)
    }

    @Test func loadedMonthIsNotLoadedAgain() async {
        let stub = StubMonthLoader([
            november: [.success(ScheduleFixtures.month(containing: november, events: []))]
        ])
        let model = model(stub)

        await model.loadIfNeeded()
        await model.loadIfNeeded()

        #expect(await stub.requests == [november])
    }

    @Test func concurrentLoadsOfAMonthShareOneRequest() async {
        let gate = LoadGate()
        let result = ScheduleFixtures.month(containing: november, events: [])
        let model = ScheduleModel(
            loader: { _ in
                await gate.enter()
                return result
            },
            today: { ScheduleFixtures.today })

        let first = Task { await model.load(november) }
        while model.isLoading == false { await Task.yield() }
        let second = Task { await model.load(november) }
        await gate.open()
        await first.value
        await second.value

        #expect(await gate.entries == 1)
        #expect(model.month == result)
        #expect(model.isLoading == false)
    }

    @Test func selectingADayInTheGridKeepsTheMonth() {
        let model = model(StubMonthLoader([:]))
        let adjacent = JapanDate(year: 2026, month: 12, day: 3)

        model.select(adjacent)

        #expect(model.displayedMonth == november)
        #expect(model.selectedDate == adjacent)
    }

    @Test func selectingADayOutsideTheGridShowsItsMonth() {
        let model = model(StubMonthLoader([:]))
        let later = JapanDate(year: 2027, month: 1, day: 20)

        model.select(later)

        #expect(model.displayedMonth == JapanDate(year: 2027, month: 1, day: 1))
        #expect(model.selectedDate == later)
    }

    @Test func pagingSelectsTheFirstDayOrToday() {
        let model = model(StubMonthLoader([:]))

        model.showMonth(offset: 1)
        #expect(model.displayedMonth == december)
        #expect(model.selectedDate == december)

        model.showMonth(offset: -1)
        #expect(model.displayedMonth == november)
        #expect(model.selectedDate == ScheduleFixtures.today)
    }

    @Test func eventLinkFindsTheEventInTheNextMonth() async throws {
        let event = try ScheduleFixtures.event(
            id: "next-month", startsOn: "2026-12-14", startsAt: "2026-12-14T12:00:00Z")
        let stub = StubMonthLoader([
            november: [.success(ScheduleFixtures.month(containing: november, events: []))],
            december: [.success(ScheduleFixtures.month(containing: december, events: [event]))],
        ])
        let model = model(stub)
        await model.loadIfNeeded()

        let found = await model.focusEvent(id: "next-month")

        #expect(found?.id == "next-month")
        #expect(model.selectedDate == JapanDate(year: 2026, month: 12, day: 14))
        #expect(model.displayedMonth == december)
    }

    @Test func eventLinkSelectsASalesOpeningDay() async throws {
        let sale = try ScheduleFixtures.event(
            id: "sale", startsOn: "2026-11-13", startsAt: "2026-11-13T03:00:00Z", typeCode: "sale",
            calendarEntries: [
                [
                    "saleMark": "opens", "startsOn": "2026-11-13", "startsAt": "2026-11-13T03:00:00Z",
                    "timePrecision": "exact",
                ],
                [
                    "saleMark": "closes", "startsOn": "2026-11-15", "startsAt": "2026-11-15T09:00:00Z",
                    "timePrecision": "exact",
                ],
            ])
        let model = model(
            StubMonthLoader([
                november: [.success(ScheduleFixtures.month(containing: november, events: [sale]))]
            ]))

        let found = await model.focusEvent(id: "sale")

        #expect(found?.id == "sale")
        #expect(model.selectedDate == JapanDate(year: 2026, month: 11, day: 13))
    }

    @Test func eventLinkToAnUnknownEventFindsNothing() async {
        let model = model(
            StubMonthLoader([november: [.success(ScheduleFixtures.month(containing: november, events: []))]]))

        let found = await model.focusEvent(id: "missing")

        #expect(found == nil)
        #expect(model.selectedDate == ScheduleFixtures.today)
    }

    @Test func swipingToAMonthSelectsTodayOrItsFirstDay() {
        let model = model(StubMonthLoader([:]))

        model.showMonth(JapanDate(year: 2027, month: 2, day: 18))
        #expect(model.displayedMonth == JapanDate(year: 2027, month: 2, day: 1))
        #expect(model.selectedDate == JapanDate(year: 2027, month: 2, day: 1))

        model.showMonth(november)
        #expect(model.displayedMonth == november)
        #expect(model.selectedDate == ScheduleFixtures.today)
    }

    @Test func swipingToTheMonthOnScreenKeepsTheSelection() {
        let model = model(StubMonthLoader([:]))
        let chosen = JapanDate(year: 2026, month: 11, day: 24)
        model.select(chosen)

        model.showMonth(november)

        #expect(model.selectedDate == chosen)
    }

    @Test func monthTitleReturnsToToday() {
        let model = model(StubMonthLoader([:]))
        model.showMonth(offset: 3)
        model.select(JapanDate(year: 2027, month: 2, day: 9))

        model.showToday()

        #expect(model.displayedMonth == november)
        #expect(model.selectedDate == ScheduleFixtures.today)
    }

    @Test func tappingADayInAGridOpensItInList() {
        let model = model(StubMonthLoader([:]))
        let tapped = JapanDate(year: 2026, month: 12, day: 3)

        let mode = model.openDay(tapped)

        #expect(mode == .list)
        #expect(model.displayedMonth == december)
        #expect(model.selectedDate == tapped)
    }

    @Test func gridAsksForTheMonthInViewThenTheMonthsBesideIt() {
        let model = model(StubMonthLoader([:]))

        #expect(
            model.monthsToLoad(around: JapanDate(year: 2027, month: 1, day: 15)) == [
                JapanDate(year: 2027, month: 1, day: 1), JapanDate(year: 2027, month: 2, day: 1), december,
            ])
    }

    @Test func gridLoadsOnlyTheMonthsNotLoadedYet() async {
        let october = JapanDate(year: 2026, month: 10, day: 1)
        let stub = StubMonthLoader([
            october: [.success(ScheduleFixtures.month(containing: october, events: []))],
            november: [.success(ScheduleFixtures.month(containing: november, events: []))],
            december: [.success(ScheduleFixtures.month(containing: december, events: []))],
        ])
        let model = model(stub)
        await model.loadIfNeeded()

        #expect(model.monthsToLoad(around: december) == [december, JapanDate(year: 2027, month: 1, day: 1)])

        await model.loadMonths(around: november)

        #expect(Set(await stub.requests) == [november, december, october])
        #expect(await stub.requests.count == 3)
        #expect(model.monthsToLoad(around: november).isEmpty)
    }

    @Test func eachMonthHasItsOwnNotice() async {
        let good = ScheduleFixtures.month(containing: november, events: [])
        let model = model(StubMonthLoader([november: [.success(good)]]))

        await model.loadMonths(around: november)

        #expect(model.notice(for: november) == nil)
        #expect(model.notice(for: december) == .loadFailed)
        #expect(model.notice(for: JapanDate(year: 2027, month: 6, day: 1)) == nil)
    }

    @Test func browsableMonthsReachAFarMonthOnScreen() {
        let model = model(StubMonthLoader([:]))
        let far = JapanDate(year: 2030, month: 4, day: 1)

        #expect(model.browsableMonths.contains(november))
        #expect(model.browsableMonths.contains(far) == false)

        model.select(far)

        #expect(model.browsableMonths.last == far)
        #expect(model.browsableMonths == model.browsableMonths.sorted())
    }
}
