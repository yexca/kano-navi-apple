import Testing

@testable import KanoNavi

/// Which motion each mode change uses, after Calendar.
struct ScheduleModeSwitchTests {
    @Test(arguments: ScheduleMode.gridModes)
    func listGrowsIntoAGridMode(_ grid: ScheduleMode) {
        #expect(
            ScheduleModeSwitch.between(.list, grid, reducesMotion: false, isInstant: false)
                == .expand(to: grid))
    }

    @Test(arguments: ScheduleMode.gridModes)
    func gridModeShrinksIntoList(_ grid: ScheduleMode) {
        #expect(
            ScheduleModeSwitch.between(grid, .list, reducesMotion: false, isInstant: false)
                == .collapse(from: grid))
    }

    @Test func gridModesRestyleInPlace() {
        #expect(
            ScheduleModeSwitch.between(.compact, .details, reducesMotion: false, isInstant: false) == .restyle
        )
        #expect(
            ScheduleModeSwitch.between(.stacked, .compact, reducesMotion: false, isInstant: false) == .restyle
        )
    }

    @Test(arguments: [(ScheduleMode.list, ScheduleMode.compact), (.details, .list), (.compact, .stacked)])
    func reduceMotionCrossFades(_ old: ScheduleMode, _ new: ScheduleMode) {
        #expect(ScheduleModeSwitch.between(old, new, reducesMotion: true, isInstant: false) == .crossFade)
    }

    @Test func deepLinksAndRepeatsAreInstant() {
        #expect(
            ScheduleModeSwitch.between(.details, .list, reducesMotion: false, isInstant: true) == .instant)
        #expect(ScheduleModeSwitch.between(.list, .list, reducesMotion: false, isInstant: false) == .instant)
        #expect(
            ScheduleModeSwitch.between(.compact, .compact, reducesMotion: true, isInstant: false) == .instant)
    }

    @Test func onlyListIsNotAGrid() {
        #expect(ScheduleMode.list.isGrid == false)
        #expect(ScheduleMode.gridModes.allSatisfy { $0.isGrid })
    }
}
