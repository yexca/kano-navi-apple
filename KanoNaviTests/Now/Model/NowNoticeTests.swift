import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowNoticeTests {
    @Test(arguments: [DashboardPhase.idle, .refreshing])
    func freshDataNeedsNoNotice(phase: DashboardPhase) {
        #expect(NowNotice(source: .network, phase: phase, isIncompatible: false) == nil)
    }

    @Test(
        arguments: [
            (DashboardPhase.refreshing, NowNotice.savedCopy(isUpdating: true)),
            (.idle, .savedCopy(isUpdating: false)),
        ] as [(DashboardPhase, NowNotice)])
    func savedSnapshotIsMarkedUntilARefreshSucceeds(phase: DashboardPhase, expected: NowNotice) {
        #expect(NowNotice(source: .cache, phase: phase, isIncompatible: false) == expected)
    }

    @Test func failedRefreshSaysWhetherTheDataIsTheSavedCopy() {
        #expect(
            NowNotice(source: .cache, phase: .failed(.offline), isIncompatible: false)
                == .failed(.offline, isSavedCopy: true))
        #expect(
            NowNotice(source: .network, phase: .failed(.http(status: 503)), isIncompatible: false)
                == .failed(.serverError(status: 503), isSavedCopy: false))
    }

    @Test func incompatibleServiceIsAFailureOverTheSavedCopy() {
        #expect(
            NowNotice(source: .cache, phase: .idle, isIncompatible: true)
                == .failed(.serviceNeedsUpdate, isSavedCopy: true))
    }
}
